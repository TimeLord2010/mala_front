import 'dart:io';

import 'package:awesome_flutter_extensions/awesome_flutter_extensions.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:mala_front/models/patient_query.dart';
import 'package:mala_front/ui/components/atoms/file_system_picker.dart';
import 'package:mala_front/usecase/file/get_export_patients_file_name.dart';
import 'package:mala_front/usecase/patient/export_patients.dart';

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
        const SizedBox(height: 20),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton(
            onPressed: isSaving
                ? null
                : () async {
                    if (path.isEmpty) return;
                    progress = 0.0001;
                    var filename = path + Platform.pathSeparator + getExportPatientsFileName();
                    await exportPatients(
                      query: widget.query,
                      filename: filename,
                      onProgress: ((total, processed) {
                        debugPrint('$processed/$total');
                        progress = processed / total;
                      }),
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
