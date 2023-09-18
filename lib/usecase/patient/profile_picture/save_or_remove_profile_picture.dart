import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:mala_front/usecase/patient/profile_picture/get_picture_file.dart';
import 'package:vit/vit.dart';

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
    logInfo('Saving profile picture of patient $patientId');
    await file.create(recursive: true);
    await file.writeAsBytes(data);
  } else {
    logInfo('Deleting profile picture of patient $patientId');
    var exists = await file.exists();
    if (exists) {
      await file.delete();
    }
  }
}
