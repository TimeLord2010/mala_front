import 'package:mala_front/usecase/http/set_jwt_header.dart';
import 'package:vit/vit.dart';

Future<void> updateJwt(String? jwt) async {
  setJwtHeader(jwt);
  var prefs = Vit().getSharedPreferences();
  if (jwt != null) {
    await prefs.setString('jwt', jwt);
  } else {
    await prefs.remove('jwt');
  }
}
