import 'package:mala_front/data/errors/failed_to_refresh_jwt.dart';
import 'package:mala_front/data/factories/logger.dart';
import 'package:mala_front/repositories/user.dart';
import 'package:mala_front/usecase/local_store/get_local_jwt.dart';
import 'package:mala_front/usecase/user/update_jwt.dart';

///
/// @throws [FailedToRefreshJwt] if not jwt token is set in the http client.
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
      logger.error('ERROR while refreshing JWT: ${e.toString()}');
      if (i++ < 3) {
        await Future.delayed(const Duration(seconds: 1));
      } else {
        throw FailedToRefreshJwt(e);
      }
    }
  }
}
