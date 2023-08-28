import 'package:fluent_ui/fluent_ui.dart';

class MalaCheckBox extends StatelessWidget {
  const MalaCheckBox({
    super.key,
    required this.label,
    required this.checked,
    required this.onCheck,
  });

  final String label;
  final bool checked;
  final void Function(bool checked) onCheck;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Checkbox(
          checked: checked,
          onChanged: (value) {
            onCheck(value ?? false);
          },
        ),
        const SizedBox(width: 5),
        Text(label),
      ],
    );
  }
}
