import 'package:mala_front/usecase/http/set_jwt_header.dart';
import 'package:vit/vit.dart';

bool isAuthenticated() {
  var prefs = Vit().getSharedPreferences();
  String? jwt = prefs.getString('jwt');
  setJwtHeader(jwt);
  return jwt != null;
}
