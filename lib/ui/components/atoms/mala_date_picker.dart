import 'package:fluent_ui/fluent_ui.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class MalaDatePicker extends StatelessWidget {
  MalaDatePicker({
    super.key,
    required this.label,
    DateTime? value,
    required this.onChanged,
  }) {
    if (value != null) {
      var day = value.day.toString().padLeft(2, '0');
      var month = value.month.toString().padLeft(2, '0');
      var yearNum = value.year;
      var year = yearNum.toString();
      controller.text = '$day/$month/$year';
    }
  }

  final String label;
  final void Function(DateTime dt) onChanged;

  final controller = TextEditingController();
  final maskFormatter = MaskTextInputFormatter(
    mask: '##/##/####',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  @override
  Widget build(BuildContext context) {
    return LimitedBox(
      maxWidth: 200,
      child: InfoLabel(
        label: label,
        child: TextBox(
          controller: controller,
          inputFormatters: [maskFormatter],
          onChanged: (value) {
            var parts = value.split('/');
            if (parts.length != 3) {
              return;
            }
            var maybeNumParts = parts.map((x) => int.tryParse(x));
            if (maybeNumParts.any((x) => x == null)) {
              return;
            }
            var numParts = maybeNumParts.whereType<int>();
            var day = numParts.elementAt(0);
            var month = numParts.elementAt(1);
            var year = numParts.elementAt(2);
            if (year < 1900) {
              return;
            }
            var date = DateTime(year, month, day);
            onChanged(date);
          },
        ),
      ),
    );
  }
}
