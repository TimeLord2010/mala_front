import 'package:mala_front/factories/local_store_repository.dart';
import 'package:mala_front/models/index.dart';

double getTagWidth() {
  var rep = createLocalStoreRepository();
  var value = rep.getDouble(LocalKeys.pdfTagWidth);

  const double defaultValue = 280.77165;
  return value ?? defaultValue;
}
