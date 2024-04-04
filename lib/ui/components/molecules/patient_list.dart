import 'package:awesome_flutter_extensions/awesome_flutter_extensions.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:mala_front/models/patient.dart';
import 'package:mala_front/ui/components/atoms/patient_tile.dart';
import 'package:mala_front/ui/pages/patient_registration.dart';

class PatientList extends StatelessWidget {
  const PatientList({
    super.key,
    required this.patients,
    this.onEdit,
    required this.modalContext,
  });

  final List<Patient> patients;
  final BuildContext modalContext;
  final void Function(Patient patient)? onEdit;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Wrap(
        children: patients.map((x) {
          return SizedBox(
            width: 350,
            child: PatientTile(
              modalContext: modalContext,
              key: ValueKey(x.id),
              patient: x,
              onPressed: onEdit != null
                  ? () async {
                      var page = PatientRegistration(
                        patient: x,
                        modalContext: modalContext,
                      );
                      await context.navigator.pushMaterial(page);
                      onEdit!(x);
                    }
                  : null,
            ),
          );
        }).toList(),
      ),
    );
  }
}
