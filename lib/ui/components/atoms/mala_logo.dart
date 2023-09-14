import 'package:fluent_ui/fluent_ui.dart';

class MalaLogo extends StatelessWidget {
  const MalaLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return LimitedBox(
      maxHeight: 300,
      child: Image.asset('assets/logo.png'),
    );
  }
}
