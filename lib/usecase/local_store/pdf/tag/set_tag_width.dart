import 'package:mala_front/factories/local_store_repository.dart';
import 'package:mala_front/factories/logger.dart';
import 'package:mala_front/models/index.dart';

Future<void> setTagWidth(double value) async {
  var rep = createLocalStoreRepository();
  if (value == 0) {
    logger.info('(setTagWidth) Removing value...');
    await rep.remove(LocalKeys.pdfTagWidth);
  }
  if (value < 20) {
    logger.warn('(setTagWidth) Aborted: value $value was too small');
    return;
  }
  if (value > 600) {
    logger.warn('(setTagWidth) Aborted: value $value was too high');
    return;
  }
  logger.info('(setTagWidth) $value');
  await rep.setDouble(LocalKeys.pdfTagWidth, value);
}
