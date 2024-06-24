import 'package:flutter/services.dart';

extension MyFormatterExtension on TextInputFormatter {
  String format(String text) {
    return formatEditUpdate(
      const TextEditingValue(),
      TextEditingValue(
        text: text,
        selection: TextSelection(
          extentOffset: text.length,
          baseOffset: text.length,
        ),
      ),
    ).text;
  }
}
