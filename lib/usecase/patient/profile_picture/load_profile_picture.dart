import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

Future<Uint8List?> loadProfilePicture(int patientId) async {
  var dir = await getApplicationDocumentsDirectory();
  var path = '${dir.path}/profilePictures/$patientId.jpg';
  var file = File(path);
  var exists = await file.exists();
  if (exists) {
    return file.readAsBytes();
  }
  return null;
}
