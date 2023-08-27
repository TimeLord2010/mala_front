import 'package:fluent_ui/fluent_ui.dart';

class ErrorMessage extends StatelessWidget {
  const ErrorMessage({
    super.key,
    required this.message,
    required this.title,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return InfoBar(
      title: Text(title),
      severity: InfoBarSeverity.error,
      content: Text(message),
    );
  }
}
