import 'package:fluent_ui/fluent_ui.dart';

class LoadProgressIndicator extends StatelessWidget {
  const LoadProgressIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: ProgressRing(),
    );
  }
}
