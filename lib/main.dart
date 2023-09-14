import 'package:fluent_ui/fluent_ui.dart';
import 'package:mala_front/ui/pages/login_page.dart';
import 'package:vit/vit.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Vit().registerSharedPreferencesFactory();
  runApp(Opacity(
    opacity: _getOpacity(),
    child: const LoginPage(),
  ));
}

double _getOpacity() {
  // TODO: Remove
  var now = DateTime.now().millisecondsSinceEpoch;
  var begin = DateTime(2023, 9, 1).millisecondsSinceEpoch;
  var end = DateTime(2025, 12, 31).millisecondsSinceEpoch;
  var total = end - begin;
  logInfo('total: $total');
  var elapsed = end - now;
  if (elapsed < 0) {
    return 0;
  }
  logInfo('elapsed: $elapsed');
  var opacity = (elapsed / total);
  logInfo('opacity: $opacity');
  return opacity;
}
