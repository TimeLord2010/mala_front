import 'package:fluent_ui/fluent_ui.dart';
import 'package:mala_front/ui/pages/login_page.dart';
import 'package:vit/vit.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Vit().registerSharedPreferencesFactory();
  runApp(const LoginPage());
}
