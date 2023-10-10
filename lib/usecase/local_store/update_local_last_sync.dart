import 'package:mala_front/factories/local_store_repository.dart';
import 'package:mala_front/models/enums/local_keys.dart';

Future<void> updateLocalLastSync(DateTime dt) async {
  var rep = createLocalStoreRepository();
  await rep.setDate(LocalKeys.lastSync, dt.toUtc());
}
