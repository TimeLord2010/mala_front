import 'package:mala_front/factories/database_client.dart';

Future<void> deleteDatabaseFiles() async {
  var isar = await createDatabaseClient();
  await isar.close(
    deleteFromDisk: true,
  );
  // String? filePath = isar.path;
  // if (filePath == null) {
  //   logError('File path not found in isar client');
  //   return;
  // }
  // var file = File(filePath);
  // bool exists = file.existsSync();
  // if (exists) {
  //   await file.delete();
  // }
  destroyDatabaseClient();
  // var files = dir.listDirectoryFiles(dir);
  // files.listen((event) async {
  //   var path = event.getName(true);
  //   if (path.contains('.isar')) {
  //     logWarn('Deleting database file: $path');
  //     event.deleteSync();
  //   } else {
  //     logInfo('Did NOT delete file: $path');
  //   }
  // });
}
