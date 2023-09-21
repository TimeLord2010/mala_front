import 'dart:io';

import 'package:mala_front/usecase/patient/profile_picture/get_patients_pictures_folder.dart';

Future<File> getPictureFile(
  int patientId, {
  String? basePath,
}) async {
  basePath ??= await getPatientsPicturesFolder();
  return File('$basePath/$patientId.jpg');
}
