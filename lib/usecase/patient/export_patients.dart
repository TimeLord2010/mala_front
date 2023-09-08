import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:mala_front/models/patient_query.dart';
import 'package:mala_front/usecase/patient/count_patients.dart';
import 'package:mala_front/usecase/patient/list_patients.dart';
import 'package:mala_front/usecase/patient/profile_picture/load_profile_picture.dart';
import 'package:mala_front/usecase/patient/profile_picture/save_profile_picture.dart';
import 'package:vit/vit.dart';

import '../file/get_export_patients_file_name.dart';

Future<void> exportPatients({
  required PatientQuery query,
  required String outputDir,
  required void Function({
    required String event,
    required double progress,
    String? message,
  }) onProgress,
  int step = 200,
}) async {
  var sep = Platform.pathSeparator;
  var date = DateTime.now();
  var values = [
    date.year,
    date.month,
    date.day,
    date.hour,
    date.minute,
    date.second,
  ].map((x) => x.toString().padLeft(2, '0')).join();
  var dir = Directory('$outputDir${sep}Mala backup [$values]');
  var filename = dir.path + sep + getExportPatientsFileName();
  var file = File(filename);
  await file.create(recursive: true);
  var total = await countPatients(query);
  var stream = file.openWrite();
  stream.write('[');
  int processed = 0;
  for (int page = 0; processed < total; page++) {
    var toBeProcessed = total - (page * step);
    var hasNextPage = toBeProcessed > step;
    var items = await listPatients(
      patientQuery: query,
      limit: step,
      skip: page * step,
    );
    logInfo('Exporting ${items.length} patients');
    var maps = items.map((x) => jsonEncode(x.toMap)).join(',');
    if (hasNextPage) {
      stream.write('$maps,');
    } else {
      stream.write(maps);
    }
    for (var patient in items) {
      var pictureData = await loadProfilePicture(patient.id);
      if (pictureData == null) continue;
      await saveProfilePicture(
        patientId: patient.id,
        data: pictureData,
        dir: dir,
      );
    }
    processed += items.length;
    var progress = processed / total;
    onProgress(
      event: 'Escrevendo dados',
      progress: progress,
      message: '$processed registros processados',
    );
    await Future.delayed(const Duration(milliseconds: 10));
  }
  logInfo('Exported $processed patients');
  stream.write(']');
  await stream.flush();
  await stream.close();
  var encoder = ZipFileEncoder();
  encoder.create('$outputDir${sep}Mala backup.zip');
  await encoder.addDirectory(
    dir,
    onProgress: (progress) {
      onProgress(
        event: 'Compactando',
        progress: progress,
      );
    },
  );
  encoder.close();
  await dir.delete(
    recursive: true,
  );
}
