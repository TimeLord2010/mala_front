import 'package:flutter/widgets.dart';

class MalaText extends StatelessWidget {
  const MalaText(
    this.text, {
    super.key,
    this.style,
  });

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style,
    );
  }
}
