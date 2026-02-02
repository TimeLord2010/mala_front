import 'package:awesome_flutter_extensions/awesome_flutter_extensions.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:mala_api/mala_api.dart';
import 'package:mala_front/ui/components/atoms/patient_tile.dart';
import 'package:mala_front/ui/pages/patient_registration.dart';

class PatientList extends StatelessWidget {
  const PatientList({
    super.key,
    required this.patients,
    this.onEdit,
    required this.modalContext,
    this.controller,
    this.footer,
  });

  final List<Patient> patients;
  final BuildContext modalContext;
  final void Function(Patient patient)? onEdit;
  final ScrollController? controller;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        var maxWidth = constraints.maxWidth;
        double tileWidth = switch (maxWidth) {
          < 600 && > 400 => (maxWidth / 2) - 5,
          _ => 300,
        };
        return SingleChildScrollView(
          controller: controller,
          child: Column(
            children: [
              Wrap(
                children: patients.map((x) {
                  return SizedBox(
                    width: tileWidth,
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
              if (footer != null) footer!,
            ],
          ),
        );
      },
    );
  }
}
