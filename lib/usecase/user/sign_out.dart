import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:mala_front/usecase/file/delete_database_files.dart';
import 'package:mala_front/usecase/patient/profile_picture/get_patients_pictures_folder.dart';
import 'package:vit/vit.dart';

import '../../factories/http_client.dart';
import 'update_jwt.dart';

Future<void> signout() async {
  dio.options.headers.clear();
  if (kDebugMode) {
    await deleteDatabaseFiles();
    await Vit().getSharedPreferences().clear();
    var dir = Directory(await getPatientsPicturesFolder());
    var exists = dir.existsSync();
    if (exists) {
      await dir.delete(recursive: true);
    }
  } else {
    await updateJwt(null);
  }
}
