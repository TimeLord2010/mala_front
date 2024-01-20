import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';

class LabeledTextBox extends StatelessWidget {
  LabeledTextBox({
    super.key,
    required this.label,
    this.formaters = const [],
    this.placeholder,
    this.onChanged,
    this.onSubmitted,
    this.isPassword = false,
    TextEditingController? controller,
  }) : controller = controller ?? TextEditingController();

  final String label;
  final String? placeholder;
  final TextEditingController controller;
  final List<TextInputFormatter> formaters;
  final bool isPassword;
  final void Function(String value)? onChanged;
  final void Function(String value)? onSubmitted;

  @override
  Widget build(BuildContext context) {
    var infoLabel = InfoLabel(
      label: label,
      child: TextBox(
        controller: controller,
        onChanged: onChanged,
        inputFormatters: formaters,
        // scrollPhysics: const ClampingScrollPhysics(),
        placeholder: placeholder,
        placeholderStyle: TextStyle(
          color: Colors.grey[80],
        ),
        obscureText: isPassword,
        onSubmitted: onSubmitted,
      ),
    );
    return LimitedBox(
      maxHeight: 50,
      maxWidth: 200,
      child: infoLabel,
    );
  }
}
