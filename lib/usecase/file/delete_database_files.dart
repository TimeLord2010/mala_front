import 'package:mala_front/usecase/file/get_database_directory.dart';
import 'package:vit/extensions/directory.dart';
import 'package:vit/vit.dart';

Future<void> deleteDatabaseFiles() async {
  if (true == true) return;
  var dir = await getDatabaseDirectory();
  var files = dir.listDirectoryFiles(dir);
  files.listen((event) async {
    var path = event.getName(true);
    if (path.contains('.isar')) {
      logInfo('Deleting database file: $path');
      event.deleteSync();
    }
  });
}
