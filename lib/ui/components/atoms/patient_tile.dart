import 'package:badges/badges.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:mala_front/models/patient.dart';
import 'package:mala_front/ui/components/atoms/mala_profile_picker.dart';
import 'package:mala_front/ui/components/molecules/simple_future_builder.dart';
import 'package:mala_front/usecase/patient/profile_picture/load_profile_picture.dart';
import 'package:mala_front/usecase/patient/profile_picture/save_or_remove_profile_picture.dart';
import 'package:vit/extensions/iterable.dart';

class PatientTile extends StatelessWidget {
  const PatientTile({
    super.key,
    required this.patient,
    this.onPressed,
  });

  final Patient patient;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    var name = patient.name ?? '';
    var phones = patient.phones ?? [];
    int? years = patient.years;
    return ListTile(
      title: Tooltip(
        message: name,
        child: Text(
          name,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      leading: Builder(builder: (context) {
        var simpleFutureBuilder = SimpleFutureBuilder(
          future: loadProfilePicture(patient.id),
          builder: (value) {
            return MalaProfilePicker(
              bytes: value,
              onRenderError: () {
                saveOrRemoveProfilePicture(patientId: patient.id, data: null);
              },
            );
          },
          contextMessage: 'Imagem de perfil',
        );
        if (patient.remoteId == null) {
          return Badge(
            badgeContent: const Icon(
              FluentIcons.refresh,
              color: Colors.white,
              size: 10,
            ),
            child: simpleFutureBuilder,
          );
        }
        return simpleFutureBuilder;
      }),
      onPressed: onPressed,
      subtitle: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: (phones.take(2).map((x) {
              return Text(x);
            }).toList())
                .separatedBy(const Text(' | ')),
          ),
          if (years != null)
            Row(
              children: [
                Text('$years anos'),
                const SizedBox(width: 5),
                if (patient.hasBirthDayThisMonth) const Text('🎂'),
                const SizedBox(width: 5),
                if (patient.isBirthdayToday) const Text('🎁'),
              ],
            ),
        ],
      ),
    );
  }
}
