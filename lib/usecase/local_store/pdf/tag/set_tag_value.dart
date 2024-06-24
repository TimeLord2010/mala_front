import 'package:mala_front/factories/local_store_repository.dart';
import 'package:mala_front/factories/logger.dart';
import 'package:mala_front/models/index.dart';

/// Generic tag value setter.
Future<void> setTagValue({
  required double minimum,
  required double maximum,
  required LocalKeys key,
  required String logKey,
  required double? value,
}) async {
  var rep = createLocalStoreRepository();

  if (value == null) {
    logger.info('($logKey) Removing value...');
    await rep.remove(LocalKeys.pdfTagWidth);
    return;
  }

  if (value < minimum) {
    logger.warn('($logKey) Aborted: value $value was too small');
    return;
  }

  if (value > maximum) {
    logger.warn('($logKey) Aborted: value $value was too high');
    return;
  }

  logger.info('($logKey) $value');
  await rep.setDouble(key, value);
}
