import 'package:mala_front/factories/local_store_repository.dart';
import 'package:mala_front/factories/logger.dart';
import 'package:mala_front/models/index.dart';

/// Sets the tag height used in pdf generation in the local store.
Future<void> setTagHeight(double value) async {
  var rep = createLocalStoreRepository();
  if (value == 0) {
    logger.info('(setTagHeight) Removing value...');
    await rep.remove(LocalKeys.pdfTagHeight);
    return;
  }
  if (value < 10) {
    logger.warn('(setTagHeight) Aborted: value $value is too small');
    return;
  }
  if (value > 140) {
    logger.warn('(setTagHeight) Aborted: value $value is too big');
    return;
  }
  logger.info('(setTagHeight) $value');
  await rep.setDouble(LocalKeys.pdfTagHeight, value);
}
