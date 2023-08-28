import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:vit/vit.dart';

Future<Uint8List?> loadProfilePicture(int patientId) async {
  var dir = await getApplicationDocumentsDirectory();
  var path = '${dir.path}/profilePictures/$patientId.jpg';
  var file = File(path);
  var exists = await file.exists();
  if (exists) {
    logInfo('Profile picture exists!');
    return file.readAsBytes();
  }
  logInfo('Profile picture does not exist');
  return null;
}
