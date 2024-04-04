import 'package:fluent_ui/fluent_ui.dart';

Future<void> showModal({
  required BuildContext context,
  required Widget? Function(BuildContext context) contentBuilder,
  List<Widget>? actions,
  String? title,
}) async {
  await showDialog(
    context: context,
    builder: (context) {
      return ContentDialog(
        title: title != null ? Text(title) : null,
        content: contentBuilder(context),
        actions: actions,
      );
    },
  );
}
