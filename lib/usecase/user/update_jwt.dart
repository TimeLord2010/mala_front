import 'package:mala_front/models/enums/local_keys.dart';
import 'package:mala_front/usecase/http/set_jwt_header.dart';
import 'package:vit/vit.dart';

Future<void> updateJwt(String? jwt) async {
  setJwtHeader(jwt);
  var prefs = Vit().getSharedPreferences();
  if (jwt != null) {
    await prefs.setString(LocalKeys.jwt.name, jwt);
  } else {
    await prefs.remove(LocalKeys.jwt.name);
  }
}
