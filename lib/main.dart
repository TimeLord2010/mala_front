import 'package:fluent_ui/fluent_ui.dart';
import 'package:mala_front/ui/pages/main_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainPage();
  }
}
