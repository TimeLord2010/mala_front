import 'package:get_it/get_it.dart';
import 'package:mala_front/usecase/http/set_jwt_header.dart';
import 'package:shared_preferences/shared_preferences.dart';

bool isAuthenticated() {
  var prefs = GetIt.I.get<SharedPreferences>();
  String? jwt = prefs.getString('jwt');
  setJwtHeader(jwt);
  return jwt != null;
}
