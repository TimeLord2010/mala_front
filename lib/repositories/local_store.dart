import 'package:mala_front/models/enums/local_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStoreRepository {
  final SharedPreferences _prefs;

  LocalStoreRepository(this._prefs);

  DateTime? getDate(LocalKeys key) {
    String? iso = _prefs.getString(key.name);
    if (iso == null) return null;
    return DateTime.parse(iso).toLocal();
  }

  Future<void> setDate(LocalKeys key, DateTime dt) async {
    await _prefs.setString(key.name, dt.toUtc().toIso8601String());
  }

  String? getString(LocalKeys key) {
    return _prefs.getString(key.name);
  }

  Future<void> setString(LocalKeys key, String value) async {
    await _prefs.setString(key.name, value);
  }
}
