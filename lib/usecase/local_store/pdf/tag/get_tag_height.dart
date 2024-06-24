import 'package:mala_front/factories/local_store_repository.dart';
import 'package:mala_front/models/index.dart';

double getTagHeight() {
  var rep = createLocalStoreRepository();
  var value = rep.getDouble(LocalKeys.pdfTagHeight);

  const double defaultValue = 73.95848;
  return value ?? defaultValue;
}
