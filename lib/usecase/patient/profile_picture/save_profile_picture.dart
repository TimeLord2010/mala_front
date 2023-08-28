import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

Future<void> saveProfilePicture({
  required int patientId,
  required Uint8List? data,
}) async {
  var dir = await getApplicationDocumentsDirectory();
  var path = '${dir.path}/profilePictures/$patientId.jpg';
  debugPrint('Patient save path: $path');
  var file = File(path);
  if (data != null) {
    await file.create(recursive: true);
    await file.writeAsBytes(data);
  } else {
    await file.delete();
  }
}
