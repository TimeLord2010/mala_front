import 'package:mala_front/repositories/user.dart';
import 'package:mala_front/usecase/local_store/get_local_jwt.dart';
import 'package:mala_front/usecase/user/update_jwt.dart';
import 'package:vit/vit.dart';

Future<void> refreshJwt() async {
  getLocalJwt();
  var rep = UserRepository();
  int i = 0;
  while (true) {
    try {
      var newJwt = await rep.generateNewJwt();
      await updateJwt(newJwt);
      return;
    } catch (e) {
      logError('ERROR while refreshing JWT: ${e.toString()}');
      if (i++ < 3) {
        await Future.delayed(const Duration(seconds: 1));
      } else {
        rethrow;
      }
    }
  }
}
