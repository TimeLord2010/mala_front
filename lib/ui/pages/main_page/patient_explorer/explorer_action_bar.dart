import 'package:awesome_flutter_extensions/awesome_flutter_extensions.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:mala_api/mala_api.dart';

import '../../../protocols/modal/export_patients_modal.dart';
import '../../patient_registration.dart';

/// Displays the main actions for the patient explorer.
///
/// This widget provides buttons for:
/// - Registering a new patient.
/// - Exporting the patient list.
/// - Printing patient tags.
/// - Printing the list of patients.
class ExplorerActionBar extends StatelessWidget {
  const ExplorerActionBar({
    super.key,
    required this.compact,
    required this.modalContext,
    required this.query,
    required this.onSearch,
  });

  final bool compact;
  final BuildContext modalContext;
  final PatientQuery query;
  final void Function({required bool reset}) onSearch;

  @override
  Widget build(BuildContext context) {
    return CommandBar(
      mainAxisAlignment: MainAxisAlignment.end,
      overflowBehavior: CommandBarOverflowBehavior.wrap,
      isCompact: compact,
      primaryItems: [
        CommandBarButton(
          icon: const Icon(FluentIcons.add),
          label: const Text('Cadastrar'),
          onPressed: () async {
            await context.navigator.pushMaterial(
              PatientRegistration(patient: null, modalContext: modalContext),
            );
            onSearch(reset: true);
          },
        ),
        CommandBarButton(
          icon: const Icon(FluentIcons.save),
          label: const Text('Exportar'),
          onPressed: () async {
            await exportPatientsModal(context, query);
          },
        ),
        CommandBarButton(
          icon: const Icon(FluentIcons.tag),
          label: const Text('Etiquetas'),
          onPressed: () async {
            var patients = await MalaApi.patient.list(
              query: query,
              limit: 5000,
            );
            var tags = patients.map(PatientTag.fromPatient);
            await MalaApi.pdf.printTags(tags: tags);
          },
        ),
        CommandBarButton(
          icon: const Icon(FluentIcons.print),
          label: const Text('Lista de pacientes'),
          onPressed: () async {
            var patients = await MalaApi.patient.list(
              query: query,
              limit: 5000,
            );
            await MalaApi.pdf.printInfo(patients: patients);
          },
        ),
      ],
    );
  }
}
