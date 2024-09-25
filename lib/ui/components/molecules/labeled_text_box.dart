import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter/services.dart';

class LabeledTextBox extends StatelessWidget {
  LabeledTextBox({
    super.key,
    required this.label,
    this.formaters = const [],
    this.placeholder,
    this.onChanged,
    this.onSubmitted,
    TextEditingController? controller,
    this.useMaterial = false,
    this.isPassword = false,
  }) : controller = controller ?? TextEditingController();

  final String label;
  final String? placeholder;
  final TextEditingController controller;
  final List<TextInputFormatter> formaters;
  final bool isPassword;
  final void Function(String value)? onChanged;
  final void Function(String value)? onSubmitted;
  final bool useMaterial;

  @override
  Widget build(BuildContext context) {
    var infoLabel = InfoLabel(
      label: label,
      child: _textbox(),
    );
    return LimitedBox(
      //maxHeight: 58,
      maxWidth: 200,
      child: infoLabel,
    );
  }

  Widget _textbox() {
    var placeholderStyle = TextStyle(
      color: Colors.grey[80],
    );
    if (useMaterial) {
      return material.Material(
        child: material.TextField(
          controller: controller,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          obscureText: isPassword,
          decoration: material.InputDecoration(
            hintText: placeholder,
            hintStyle: placeholderStyle,
          ),
        ),
      );
    }
    return TextBox(
      controller: controller,
      onChanged: onChanged,
      inputFormatters: formaters,
      // scrollPhysics: const ClampingScrollPhysics(),
      placeholder: placeholder,
      placeholderStyle: placeholderStyle,
      obscureText: isPassword,
      onSubmitted: onSubmitted,
    );
  }
}
