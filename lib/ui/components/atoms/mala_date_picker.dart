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
      var year = value.year.toString().substring(2);
      controller.text = '$day/$month/$year';
    }
  }

  final String label;
  final void Function(DateTime dt) onChanged;

  // final dayController = TextEditingController();
  // final monthController = TextEditingController();
  // final yearController = TextEditingController();
  final controller = TextEditingController();
  final maskFormatter = MaskTextInputFormatter(
    mask: '##/##/##',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  @override
  Widget build(BuildContext context) {
    return InfoLabel(
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
          var date = DateTime(year, month, day);
          onChanged(date);
        },
      ),
      // child: Row(
      //   children: [
      //     _createTextBox(dayController),
      //     _createTextBox(monthController),
      //     _createTextBox(yearController),
      //   ].separatedBy(const SizedBox(width: 10)),
      // ),
    );
  }

  Widget _createTextBox(TextEditingController controller) {
    return SizedBox(
      width: 60,
      child: TextBox(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(
          decimal: false,
          signed: false,
        ),
        onChanged: (v) {
          //_onTextChanged();
        },
      ),
    );
  }

  // void _onTextChanged() {
  //   int? day = int.tryParse(dayController.text);
  //   if () {

  //   }
  // }
}
