import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:mala_front/models/patient_query.dart';
import 'package:mala_front/usecase/file/get_export_patients_file_name.dart';
import 'package:mala_front/usecase/patient/export_patients.dart';

class ExportPatientsPane extends StatefulWidget {
  ExportPatientsPane({
    super.key,
    required this.close,
    required this.query,
  });

  final void Function() close;
  final PatientQuery query;

  final controller = TextEditingController();

  @override
  State<ExportPatientsPane> createState() => _ExportPatientsPaneState();
}

class _ExportPatientsPaneState extends State<ExportPatientsPane> {
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
        Row(
          children: [
            const Text(
              'Selecione o destino:',
            ),
            const SizedBox(width: 20),
            Expanded(
                child: TextBox(
              controller: widget.controller,
            )),
            const SizedBox(width: 20),
            FilledButton(
              child: const Text('Selecionar'),
              onPressed: () async {
                var picked = await FilePicker.platform.saveFile(
                  dialogTitle: 'Selecione o destino',
                  allowedExtensions: ['json', 'txt'],
                  fileName: getExportPatientsFileName(),
                );
                path = picked ?? '';
                widget.controller.text = path;
              },
            ),
          ],
        ),
        const SizedBox(height: 30),
        if (progress != null)
          ProgressBar(
            value: (progress! * 100),
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
                    await exportPatients(
                      query: widget.query,
                      filename: path,
                      onProgress: ((total, processed) {
                        debugPrint('$processed/$total');
                        progress = processed / total;
                      }),
                    );
                    progress = 1;
                  },
            child: const Text('Exportar'),
          ),
        ),
      ],
    );
  }
}
