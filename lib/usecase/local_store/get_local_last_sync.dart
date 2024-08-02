import 'package:mala_front/data/enums/local_keys.dart';

import '../../data/factories/local_store_repository.dart';

DateTime? getLocalLastSync() {
  var rep = createLocalStoreRepository();
  return rep.getDate(LocalKeys.lastSync)?.toUtc();
}
