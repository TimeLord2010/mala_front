import 'package:awesome_flutter_extensions/awesome_flutter_extensions.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:mala_front/models/patient.dart';

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
      leading: const CircleAvatar(
        child: Icon(
          FluentIcons.contact,
          size: 20,
        ),
      ),
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
