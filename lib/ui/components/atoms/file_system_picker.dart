import 'package:fluent_ui/fluent_ui.dart';
import 'package:mala_front/usecase/file/pick_file.dart';
import 'package:mala_front/usecase/file/pick_folder.dart';

class FileSystemPicker extends StatelessWidget {
  FileSystemPicker({
    super.key,
    required this.onPick,
    required String? path,
    this.isFolder = false,
    String? label,
  })  : controller = TextEditingController(
          text: path,
        ),
        label = label ?? (isFolder ? 'Escolha a pasta' : 'Escolha o arquivo');

  final TextEditingController controller;
  final void Function(String? path) onPick;
  final String label;
  final bool isFolder;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label),
        const SizedBox(width: 20),
        Expanded(
          child: TextBox(
            controller: controller,
          ),
        ),
        const SizedBox(width: 20),
        Button(
          onPressed: _onPress,
          child: const Text('Escolher'),
        ),
      ],
    );
  }

  void _onPress() async {
    if (isFolder) {
      var picked = await pickFolder();
      onPick(picked);
    } else {
      var picked = await pickFile();
      onPick(picked);
    }
  }
}
