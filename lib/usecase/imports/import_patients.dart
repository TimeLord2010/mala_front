import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive_io.dart';
import 'package:isar/isar.dart';
import 'package:mala_front/models/patient.dart';
import 'package:mala_front/usecase/file/get_export_patients_file_name.dart';
import 'package:mala_front/usecase/imports/load_patients_from_json.dart';
import 'package:mala_front/usecase/patient/list_patients_by_creation_dates.dart';
import 'package:mala_front/usecase/patient/profile_picture/get_picture_file.dart';
import 'package:mala_front/usecase/patient/upsert_patient.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vit/extensions/iterable.dart';
import 'package:vit/vit.dart';

Future<List<Patient>> importPatients({
  required String zipFileName,
}) async {
  var dir = await getApplicationDocumentsDirectory();
  logInfo('zipFile: $zipFileName');
  await extractFileToDisk(
    zipFileName,
    dir.path,
  );
  var entities = dir.listSync();
  var backupFolders = entities.where((x) {
    return x is Directory && x.path.contains('Mala backup');
  });
  if (backupFolders.isEmpty) {
    throw Exception('No backup folder found after extraction.');
  }
  var backupFolder = backupFolders.first;
  var sep = Platform.pathSeparator;
  var picturesFolder = Directory(backupFolder.path);
  var picFolderExists = picturesFolder.existsSync();
  Future<Uint8List?> getPic(int id) async {
    if (!picFolderExists) {
      return null;
    }
    var file = await getPictureFile(
      id,
      basePath: picturesFolder.path,
    );
    var exists = file.existsSync();
    if (exists) {
      return file.readAsBytes();
    }
    return null;
  }

  try {
    var filename = backupFolder.path + sep + getExportPatientsFileName();
    var patients = await loadPatientsFromJson(
      filename: filename,
    );
    var chuncks = patients.chunck(50);
    var added = <Patient>[];
    for (var chunck in chuncks) {
      var creationDates = chunck.map((x) => x.createdAt).whereType<DateTime>();
      var foundAlreadySaved = await listPatientsByCreation(
        createdAts: creationDates,
      );
      bool hasCreated(DateTime dt) {
        return foundAlreadySaved.any((x) => x.createdAt == dt);
      }

      var newRecords = chunck.where((x) {
        var createdAt = x.createdAt;
        if (createdAt == null) return true;
        return !hasCreated(createdAt);
      });
      for (var record in newRecords) {
        var picData = await getPic(record.id);
        record.id = Isar.autoIncrement;
        await upsertPatient(
          record,
          pictureData: picData,
        );
      }
      added.addAll(newRecords);

      // To implement already existing restoration of users, each user would
      // need to be reviewed to every change OR the system could
      // automatically pick the must recent updated.

      // var existingRecords = chunck.where((x) {
      //   var createdAt = x.createdAt;
      //   if (createdAt == null) return false;
      //   return hasCreated(createdAt);
      // });
    }
    return added;
  } finally {
    await backupFolder.delete(
      recursive: true,
    );
  }
}
