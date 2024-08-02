import 'package:mala_front/data/enums/local_keys.dart';
import 'package:mala_front/data/factories/local_store_repository.dart';

Future<void> updateLocalLastSync(DateTime dt) async {
  var rep = createLocalStoreRepository();
  await rep.setDate(LocalKeys.lastSync, dt.toUtc());
}
