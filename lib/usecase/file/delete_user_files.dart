import 'dart:io';

import 'package:mala_front/usecase/http/set_jwt_header.dart';
import 'package:vit/vit.dart';

import '../patient/profile_picture/get_patients_pictures_folder.dart';
import 'delete_database_files.dart';

Future<void> deleteUserFiles() async {
  await deleteDatabaseFiles();
  await Vit().getSharedPreferences().clear();
  setJwtHeader(null);
  var dir = Directory(await getPatientsPicturesFolder());
  var exists = dir.existsSync();
  if (exists) {
    await dir.delete(recursive: true);
  }
  await Future.delayed(const Duration(seconds: 1));
}
