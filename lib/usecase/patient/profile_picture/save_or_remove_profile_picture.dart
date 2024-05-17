import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:mala_front/factories/logger.dart';
import 'package:mala_front/usecase/patient/profile_picture/get_picture_file.dart';

Future<void> saveOrRemoveProfilePicture({
  required int patientId,
  required Uint8List? data,
  Directory? dir,
}) async {
  var file = await getPictureFile(
    patientId,
    basePath: dir?.path,
  );
  if (data != null) {
    logger.info('Saving pacient picture $patientId');
    await file.create(recursive: true);
    await file.writeAsBytes(data);
  } else {
    logger.info('No pacient picture found $patientId');
    var exists = file.existsSync();
    if (exists) {
      await file.delete();
    }
  }
}
