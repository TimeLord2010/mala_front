import 'package:awesome_flutter_extensions/awesome_flutter_extensions.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:mala_api/mala_api.dart';
import 'package:mala_front/ui/components/atoms/file_system_picker.dart';

class ExportPatientsPane extends StatefulWidget {
  const ExportPatientsPane({
    super.key,
    required this.close,
    required this.query,
  });

  final void Function() close;
  final PatientQuery query;

  @override
  State<ExportPatientsPane> createState() => _ExportPatientsPaneState();
}

class _ExportPatientsPaneState extends State<ExportPatientsPane> {
  String event = '';
  String eventMessage = '';

  double? _progress = 0;
  double? get progress => _progress;
  set progress(double? value) {
    setState(() {
      _progress = value;
    });
  }

  String _path = '';
  String get path => _path;
  set path(String value) {
    setState(() {
      _path = value;
    });
  }

  bool get isSaving {
    return progress != 0 && progress != 1;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FileSystemPicker(
          onPick: (picked) {
            path = picked ?? '';
          },
          path: path,
          isFolder: true,
        ),
        const SizedBox(height: 30),
        if (progress != null)
          ProgressBar(
            value: (progress! * 100),
          ),
        Text(event),
        Text(
          eventMessage,
          style: const TextStyle(
            color: Color.fromARGB(255, 124, 124, 124),
          ),
        ),
        const SizedBox(height: 20),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton(
            onPressed: isSaving
                ? null
                : () async {
                    if (path.isEmpty) return;
                    progress = 0.0001;
                    await MalaApi.file.export(
                      query: widget.query,
                      outputDir: path,
                      onProgress: ({
                        required String event,
                        required double progress,
                        String? message,
                      }) {
                        this.event = event;
                        eventMessage = message ?? '';
                        this.progress = progress;
                      },
                    );
                    progress = 1;
                    context.navigator.pop();
                  },
            child: const Text('Exportar'),
          ),
        ),
      ],
    );
  }
}
