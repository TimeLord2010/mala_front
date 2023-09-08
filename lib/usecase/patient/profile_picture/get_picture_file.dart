import 'dart:io';

import 'package:path_provider/path_provider.dart';

Future<File> getPictureFile(
  int patientId, {
  String? basePath,
}) async {
  if (basePath == null) {
    var dir = await getApplicationDocumentsDirectory();
    basePath = dir.path;
  }
  return File('$basePath/profilePictures/$patientId.jpg');
}
