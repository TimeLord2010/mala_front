import 'package:awesome_flutter_extensions/awesome_flutter_extensions.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:mala_front/models/patient.dart';
import 'package:mala_front/ui/components/molecules/labeled_text_box.dart';

class PatientRegistration extends StatelessWidget {
  PatientRegistration({
    super.key,
    this.patient,
  }) {
    if (patient == null) {
      return;
    }
    // TODO: populate controller
  }

  final Patient? patient;
  final nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return FluentApp(
      home: NavigationView(
        appBar: NavigationAppBar(
          leading: IconButton(
            icon: const Icon(FluentIcons.back),
            onPressed: () {
              context.navigator.pop();
            },
          ),
        ),
        content: Column(
          children: [
            LabeledTextBox(
              label: 'Nome',
            ),
          ],
        ),
      ),
    );
  }
}
