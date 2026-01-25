import 'package:fluent_ui/fluent_ui.dart';
import 'package:get_it/get_it.dart';
import 'package:mala_front/ui/pages/login_page.dart';
import 'package:mala_front/ui/providers/server_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  var sp = await SharedPreferences.getInstance();
  GetIt.I.registerSingleton(sp);
  var instance = ServerProvider();
  instance.refreshHttpClient(instance.address);
  runApp(const LoginPage());
}
