import 'dart:io';

import 'package:path_provider/path_provider.dart';

Future<String> getPatientsPicturesFolder() async {
  Future<String> getBase() async {
    if (Platform.isWindows) {
      var dir = await getApplicationSupportDirectory();
      return dir.path;
    } else {
      var dir = await getApplicationDocumentsDirectory();
      return dir.path;
    }
  }

  var base = await getBase();
  return '$base/profilePictures';
}
