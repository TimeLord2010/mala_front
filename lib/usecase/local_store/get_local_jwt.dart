import 'package:mala_front/factories/local_store_repository.dart';
import 'package:mala_front/models/enums/local_keys.dart';
import 'package:mala_front/models/errors/missing_local_jwt.dart';

String getLocalJwt() {
  var rep = createLocalStoreRepository();
  var jwt = rep.getString(LocalKeys.jwt);
  if (jwt == null) throw MissingLocalJwt();
  return jwt;
}
