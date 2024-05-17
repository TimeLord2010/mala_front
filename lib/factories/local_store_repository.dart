import 'package:get_it/get_it.dart';
import 'package:mala_front/repositories/local_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

LocalStoreRepository createLocalStoreRepository() {
  var prefs = GetIt.I.get<SharedPreferences>();
  return LocalStoreRepository(prefs);
}
