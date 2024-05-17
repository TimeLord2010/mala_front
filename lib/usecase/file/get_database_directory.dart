import 'dart:io';

import 'package:mala_front/factories/logger.dart';
import 'package:path_provider/path_provider.dart';

Future<Directory> getDatabaseDirectory() async {
  Future<Directory> getDir() async {
    if (Platform.isIOS || Platform.isMacOS) {
      var dir = await getLibraryDirectory();
      return dir;
    }
    if (Platform.isWindows) {
      var dir = await getApplicationSupportDirectory();
      return dir;
    }
    var dir = await getApplicationDocumentsDirectory();
    return dir;
  }

  var dir = await getDir();
  logger.info('Database directory: ${dir.path}');
  return dir;
}
