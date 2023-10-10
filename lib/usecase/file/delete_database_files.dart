import 'dart:io';

import 'package:mala_front/factories/database_client.dart';
import 'package:mala_front/usecase/error/get_error_message.dart';
import 'package:mala_front/usecase/file/get_database_directory.dart';
import 'package:vit/extensions/directory.dart';
import 'package:vit/vit.dart';

Future<void> deleteDatabaseFiles() async {
  var isar = await createDatabaseClient();
  String? filePath = isar.path;
  await isar.close(
    deleteFromDisk: true,
  );
  if (filePath != null) {
    logInfo('Database file: $filePath');
    var file = File(filePath);
    bool exists = file.existsSync();
    if (exists) {
      try {
        await file.delete();
      } catch (e) {
        logError('Failed to delete database file: ${getErrorMessage(e)}');
      }
    }
  }
  destroyDatabaseClient();
  var dir = await getDatabaseDirectory();
  var files = dir.listDirectoryFiles(dir);
  files.listen((event) async {
    var path = event.getName(true);
    if (path.contains('.isar')) {
      logWarn('Deleting database file: $path');
      event.deleteSync();
    } else {
      logInfo('Did NOT delete file: $path');
    }
  });
}
