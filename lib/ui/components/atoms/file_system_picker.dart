import 'package:fluent_ui/fluent_ui.dart';
import 'package:mala_front/usecase/file/pick_file.dart';
import 'package:mala_front/usecase/file/pick_folder.dart';

class FileSystemPicker extends StatelessWidget {
  FileSystemPicker({
    super.key,
    required this.onPick,
    required String? path,
    this.isFolder = false,
    this.label = 'Escolha a pasta',
  }) : controller = TextEditingController(
          text: path,
        );

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
        FilledButton(
          onPressed: () async {
            if (isFolder) {
              var picked = await pickFolder();
              onPick(picked);
            } else {
              var picked = await pickFile();
              onPick(picked);
            }
          },
          child: const Text('Escolher'),
        ),
      ],
    );
  }
}
