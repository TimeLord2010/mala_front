import 'package:mala_front/repositories/user.dart';
import 'package:mala_front/usecase/user/update_jwt.dart';
import 'package:vit/vit.dart';

Future<void> refreshJwt() async {
  var pref = Vit().getSharedPreferences();
  var jwt = pref.getString('jwt');
  if (jwt == null) {
    throw Exception('No jwt saved found.');
  }
  var rep = UserRepository();
  int i = 0;
  while (true) {
    try {
      var newJwt = await rep.generateNewJwt();
      updateJwt(newJwt);
      return;
    } on Exception catch (e) {
      logInfo('ERROR while refreshing JWT: ${e.toString()}');
      if (i++ < 3) {
        await Future.delayed(const Duration(seconds: 1));
      } else {
        rethrow;
      }
    }
  }
}
