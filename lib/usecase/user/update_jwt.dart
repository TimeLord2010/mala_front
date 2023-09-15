import 'package:mala_front/usecase/http/set_jwt_header.dart';
import 'package:vit/vit.dart';

void updateJwt(String? jwt) {
  setJwtHeader(jwt);
  var prefs = Vit().getSharedPreferences();
  if (jwt != null) {
    prefs.setString('jwt', jwt);
  } else {
    prefs.remove('jwt');
  }
}
