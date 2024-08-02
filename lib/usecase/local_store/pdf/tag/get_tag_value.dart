import 'package:mala_front/data/entities/index.dart';
import 'package:mala_front/data/factories/local_store_repository.dart';

double getTagValue(LocalKeys key, double defaultValue) {
  var rep = createLocalStoreRepository();
  var value = rep.getDouble(key);

  return value ?? defaultValue;
}
