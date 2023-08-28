import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';

class LabeledTextBox extends StatefulWidget {
  LabeledTextBox({
    super.key,
    required this.label,
    this.formaters = const [],
    this.placeholder,
    TextEditingController? controller,
  }) : controller = controller ?? TextEditingController();

  final String label;
  final String? placeholder;
  final TextEditingController controller;
  final List<TextInputFormatter> formaters;

  @override
  State<StatefulWidget> createState() {
    return LabeledTextBoxState();
  }
}

class LabeledTextBoxState extends State<LabeledTextBox> {
  bool _isEmpty = true;
  bool get isEmpty => _isEmpty;
  set isEmpty(bool value) {
    if (value == _isEmpty) return;
    setState(() {
      _isEmpty = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    var infoLabel = InfoLabel(
      label: widget.label,
      child: TextBox(
        controller: widget.controller,
        onChanged: (value) {
          isEmpty = value.isEmpty;
        },
        inputFormatters: widget.formaters,
        placeholder: widget.placeholder,
        placeholderStyle: TextStyle(
          color: Colors.grey[80],
        ),
      ),
    );
    return LimitedBox(
      maxHeight: 50,
      maxWidth: 200,
      child: infoLabel,
    );
  }
}
