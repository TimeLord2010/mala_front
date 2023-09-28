import 'package:mala_front/repositories/local_store.dart';
import 'package:vit/vit.dart';

LocalStoreRepository createLocalStoreRepository() {
  var prefs = Vit().getSharedPreferences();
  return LocalStoreRepository(prefs);
}
