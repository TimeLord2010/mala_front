import 'package:fluent_ui/fluent_ui.dart';
import 'package:mala_front/ui/components/atoms/error_message.dart';
import 'package:mala_front/ui/components/atoms/load_progress_indicator.dart';

class SimpleFutureBuilder<T> extends StatelessWidget {
  const SimpleFutureBuilder({
    super.key,
    required this.future,
    required this.builder,
    required this.contextMessage,
  });

  final Future<T> future;
  final Widget Function(T value) builder;

  /// This is used to display the error message.
  ///
  /// This value should be in portuguese.
  final String contextMessage;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future,
      builder: (context, snap) {
        if (snap.hasData) {
          var data = snap.requireData;
          return builder(data);
        }
        if (snap.hasError) {
          return ErrorMessage(
            message: snap.error.toString(),
            title: contextMessage,
          );
        }
        return const LoadProgressIndicator();
      },
    );
  }
}
