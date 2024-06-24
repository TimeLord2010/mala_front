import 'package:mala_front/factories/local_store_repository.dart';
import 'package:mala_front/models/index.dart';

double getTagValue(LocalKeys key, double defaultValue) {
  var rep = createLocalStoreRepository();
  var value = rep.getDouble(key);

  return value ?? defaultValue;
}
