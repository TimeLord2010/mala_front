import 'package:fluent_ui/fluent_ui.dart';
import 'package:mala_front/ui/components/atoms/file_system_picker.dart';

class ImportPatients extends StatefulWidget {
  const ImportPatients({super.key});

  @override
  State<ImportPatients> createState() => _ImportPatientsState();
}

class _ImportPatientsState extends State<ImportPatients> {
  String? _path;
  String? get path => _path;
  set path(String? value) {
    setState(() {
      _path = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          FileSystemPicker(
            onPick: (picked) {
              path = picked;
            },
            path: path,
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: path == null ? null : () {},
              child: const Text('Importar'),
            ),
          ),
        ],
      ),
    );
  }
}
