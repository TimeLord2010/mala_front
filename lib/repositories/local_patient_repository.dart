import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive_io.dart';
import 'package:flutter/widgets.dart';
import 'package:isar/isar.dart';
import 'package:mala_front/data/entities/patient.dart';
import 'package:mala_front/data/entities/patient_query.dart';
import 'package:mala_front/data/factories/logger.dart';
import 'package:mala_front/data/interfaces/patient_interface.dart';
import 'package:mala_front/usecase/file/get_export_patients_file_name.dart';
import 'package:mala_front/usecase/imports/load_patients_from_json.dart';
import 'package:mala_front/usecase/patient/profile_picture/get_picture_file.dart';
import 'package:mala_front/usecase/patient/upsert_patient.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vit_dart_extensions/vit_dart_extensions.dart';
import 'package:vit_logger/vit_logger.dart';

class LocalPatientRepository extends PatientInterface {
  final Isar isar;

  LocalPatientRepository(this.isar);

  /// Fetches the patients who do not have the "remoteId" field set.
  Future<List<Patient>> findLocalPatients({
    required int skip,
    required int limit,
  }) {
    var stopWatch = VitStopWatch('findLocalPatients');
    var query = isar.patients.where();
    var patients = query.remoteIdIsNull().offset(skip).limit(limit).findAll();
    stopWatch.stop();
    return patients;
  }

  Future<int?> findIdByRemoteId(String remoteId) async {
    var where = isar.patients.where();
    var id = await where.remoteIdEqualTo(remoteId).idProperty().findFirst();
    return id;
  }

   @override
  Future<List<Patient>> list(
    PatientQuery query, {
    int? skip,
    int? limit,
  }) async {
    var docs = await query.buildQuery(isar).offset(skip ?? 0).limit(limit ?? 60).findAll();
    return docs;
  }

  Future<Patient?> findById(int id) async {
    var patient = await isar.patients.get(id);
    return patient;
  }

  Future<List<Patient>> findByIds(List<int> ids) {
    var where = isar.patients.where();
    var first = ids.removeAt(0);
    var afterWhere = where.idEqualTo(first);
    while (ids.isNotEmpty) {
      afterWhere = afterWhere.or().idEqualTo(ids.removeAt(0));
    }
    return afterWhere.findAll();
  }

  @override
  Future<Iterable<Patient>> listByCreation({
    required Iterable<DateTime> createdAts,
  }) async {
    if (createdAts.isEmpty) return [];
    var where = isar.patients.where();
    var query = where.createdAtIsNotNull();
    for (var dt in createdAts) {
      query = query.or().createdAtEqualTo(dt);
    }
    return query.findAll();
  }

  @override
  Future<int> count([PatientQuery? query]) async {
    if (query == null) {
      return isar.patients.count();
    }
    var count = await query.buildQuery(isar).count();
    return count;
  }

  Future<Patient> insert(Patient patient) async {
    // var oldId = patient.id;
    await isar.writeTxn(() async {
      var hadId = patient.id > 0;
      var id = await isar.patients.put(patient);
      if (!hadId) debugPrint('New id: $id');
    });
    // var inserted = oldId != patient.id;
    // if (inserted) {
    //   logger.info('INSERTED PATIENT!!!');
    // } else {
    //   logger.info('UPDATED PATIENT!!!');
    // }
    var address = patient.address.value;
    if (address != null) {
      await isar.writeTxn(() async {
        await isar.address.put(address);
        await patient.address.save();
      });
    }
    return patient;
  }

  @override
  Future<void> delete(dynamic id) async {
    if (id is String) {
      id = int.tryParse(id);
    }
    if (id is! int) {
      throw ArgumentError('Patient id needs to be a int.');
    }
    await isar.writeTxn(() async {
      await isar.patients.delete(id);
    });
  }

  @override
  Future<Patient> upsert(Patient patient) {
    return insert(patient);
  }

  Future<List<Patient>> importPatients({
  required String zipFileName,
  required BuildContext? context,
}) async {
  var dir = await getApplicationDocumentsDirectory();
  logger.info('zipFile: $zipFileName');
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
      var foundAlreadySaved = await listByCreation(
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
          context: context,
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

  @override
  Future<Patient> getById(String id) {
    // TODO: implement getById
    throw UnimplementedError();
  }
}
