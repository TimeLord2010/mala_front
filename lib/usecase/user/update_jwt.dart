import 'package:get_it/get_it.dart';
import 'package:mala_front/factories/logger.dart';
import 'package:mala_front/models/enums/local_keys.dart';
import 'package:mala_front/usecase/http/set_jwt_header.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> updateJwt(String? jwt) async {
  setJwtHeader(jwt);
  var prefs = GetIt.I.get<SharedPreferences>();
  if (jwt != null) {
    logger.debug('Removing jwt from local storage');
    await prefs.setString(LocalKeys.jwt.name, jwt);
  } else {
    await prefs.remove(LocalKeys.jwt.name);
  }
}
