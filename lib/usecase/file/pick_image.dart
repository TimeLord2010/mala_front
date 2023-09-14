import 'package:file_picker/file_picker.dart';

Future<String?> pickImage() async {
  var result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['jpg', 'jpeg'],
    //type: FileType.image,
  );
  if (result == null || result.count == 0) return null;
  var file = result.files.first;
  return file.path;
}
