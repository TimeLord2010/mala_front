import 'package:mala_front/models/enums/local_keys.dart';

import '../../factories/local_store_repository.dart';

DateTime? getLocalLastSync() {
  var rep = createLocalStoreRepository();
  return rep.getDate(LocalKeys.lastSync)?.toLocal();
}
