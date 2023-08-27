import 'package:fluent_ui/fluent_ui.dart';
import 'package:mala_front/ui/components/molecules/simple_future_builder.dart';
import 'package:mala_front/ui/components/organisms/patient_list.dart';
import 'package:mala_front/usecase/patient/list_patients.dart';

class PatientExplorer extends StatelessWidget {
  const PatientExplorer({super.key});

  @override
  Widget build(BuildContext context) {
    return SimpleFutureBuilder(
      future: listPatients(),
      builder: (patients) {
        return PatientList(
          patients: patients,
        );
      },
      contextMessage: 'Falha na listagem de pacientes',
    );
  }
}
