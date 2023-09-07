import 'package:file_picker/file_picker.dart';

Future<String?> pickFile() async {
  var pick = await FilePicker.platform.pickFiles(
    allowedExtensions: ['zip'],
    type: FileType.custom,
  );
  if (pick == null) return null;
  return pick.files.firstOrNull?.path;
}
