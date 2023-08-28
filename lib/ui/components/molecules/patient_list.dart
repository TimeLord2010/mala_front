import 'package:awesome_flutter_extensions/awesome_flutter_extensions.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:mala_front/models/patient.dart';
import 'package:mala_front/ui/components/atoms/patient_tile.dart';
import 'package:mala_front/ui/pages/patient_registration.dart';

class PatientList extends StatelessWidget {
  const PatientList({
    super.key,
    required this.patients,
    required this.onEdit,
  });

  final List<Patient> patients;
  final void Function(Patient patient) onEdit;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Wrap(
        children: patients.map((x) {
          return SizedBox(
            width: 350,
            child: PatientTile(
              patient: x,
              onPressed: () async {
                await context.navigator.pushMaterial(PatientRegistration(
                  patient: x,
                ));
                onEdit(x);
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}
