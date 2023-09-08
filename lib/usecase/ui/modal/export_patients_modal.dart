import 'package:fluent_ui/fluent_ui.dart';
import 'package:mala_front/models/patient_query.dart';

import '../../../ui/components/molecules/export_patients_pane.dart';

Future<void> exportPatientsModal(BuildContext context, PatientQuery query) async {
  await showDialog(
    context: context,
    builder: (context) {
      return ContentDialog(
        title: const Text('Exportar pacientes'),
        constraints: const BoxConstraints(
          maxWidth: 500,
        ),
        content: ExportPatientsPane(
          close: () {
            Navigator.pop(context);
          },
          query: query,
        ),
        actions: [
          Button(
            child: const Text('Cancelar'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      );
    },
  );
}
