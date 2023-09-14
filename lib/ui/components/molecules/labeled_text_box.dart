import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';

class LabeledTextBox extends StatelessWidget {
  LabeledTextBox({
    super.key,
    required this.label,
    this.formaters = const [],
    this.placeholder,
    this.onChange,
    this.isPassword = false,
    TextEditingController? controller,
  }) : controller = controller ?? TextEditingController();

  final String label;
  final String? placeholder;
  final TextEditingController controller;
  final List<TextInputFormatter> formaters;
  final bool isPassword;
  final void Function(String value)? onChange;

  @override
  Widget build(BuildContext context) {
    var infoLabel = InfoLabel(
      label: label,
      child: TextBox(
        controller: controller,
        onChanged: onChange,
        inputFormatters: formaters,
        placeholder: placeholder,
        placeholderStyle: TextStyle(
          color: Colors.grey[80],
        ),
        obscureText: isPassword,
      ),
    );
    return LimitedBox(
      maxHeight: 50,
      maxWidth: 200,
      child: infoLabel,
    );
  }
}
