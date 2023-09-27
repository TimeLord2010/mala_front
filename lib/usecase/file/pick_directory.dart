import 'dart:io';

import 'package:file_picker/file_picker.dart';

Future<Directory?> pickDirectory() async {
  var result = await FilePicker.platform.getDirectoryPath();
  if (result == null) return null;
  return Directory(result);
}
