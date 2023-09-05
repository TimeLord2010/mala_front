import 'package:file_picker/file_picker.dart';

Future<String?> pickFolder([String? title]) async {
  var picked = await FilePicker.platform.getDirectoryPath(
    dialogTitle: title ?? 'Escolha a pasta',
  );
  return picked;
}
