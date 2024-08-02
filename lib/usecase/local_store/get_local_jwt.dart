import 'package:mala_front/data/enums/local_keys.dart';
import 'package:mala_front/data/errors/missing_local_jwt.dart';
import 'package:mala_front/data/factories/local_store_repository.dart';

String getLocalJwt() {
  var rep = createLocalStoreRepository();
  var jwt = rep.getString(LocalKeys.jwt);
  if (jwt == null) throw MissingLocalJwt();
  return jwt;
}
