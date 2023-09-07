import 'package:archive/archive_io.dart';
import 'package:path_provider/path_provider.dart';

Future<void> importPatients({
  required String zipFileName,
}) async {
  var dir = await getApplicationDocumentsDirectory();
  await extractFileToDisk(
    zipFileName,
    dir.path,
    asyncWrite: true,
  );
}
