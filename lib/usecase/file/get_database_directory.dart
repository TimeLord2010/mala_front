import 'dart:io';

import 'package:path_provider/path_provider.dart';

Future<Directory> getDatabaseDirectory() async {
  if (Platform.isIOS || Platform.isMacOS) {
    var dir = await getLibraryDirectory();
    return dir;
  }
  var dir = await getApplicationDocumentsDirectory();
  return dir;
}
