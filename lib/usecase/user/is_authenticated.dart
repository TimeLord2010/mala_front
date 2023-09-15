import 'package:vit/vit.dart';

bool isAuthenticated() {
  var prefs = Vit().getSharedPreferences();
  return prefs.containsKey('jwt');
}
