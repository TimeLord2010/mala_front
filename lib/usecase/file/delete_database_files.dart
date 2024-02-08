import 'dart:io';

import 'package:mala_front/factories/database_client.dart';
import 'package:mala_front/usecase/error/get_error_message.dart';
import 'package:mala_front/usecase/file/get_database_directory.dart';
import 'package:vit/extensions/directory.dart';
import 'package:vit/vit.dart' as vit;

Future<void> deleteDatabaseFiles() async {
  var isar = await createDatabaseClient();
  String? filePath = isar.path;
  await isar.close(
    deleteFromDisk: true,
  );
  if (filePath != null) {
    vit.logInfo('Database file: $filePath');
    var file = File(filePath);
    bool exists = file.existsSync();
    if (exists) {
      try {
        await file.delete();
      } catch (e) {
        vit.logError('Failed to delete database file: ${getErrorMessage(e)}');
      }
    }
  }
  destroyDatabaseClient();
  var dir = await getDatabaseDirectory();
  var files = dir.listDirectoryFiles(dir);
  files.listen((event) async {
    var path = event.getName(true);
    if (path.contains('.isar')) {
      vit.logWarn('Deleting database file: $path');
      event.deleteSync();
    } else {
      vit.logInfo('Did NOT delete file: $path');
    }
  });
}
