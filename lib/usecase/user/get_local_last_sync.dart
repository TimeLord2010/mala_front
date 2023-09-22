import 'package:vit/vit.dart';

DateTime? getLocalLastSync() {
  var prefs = Vit().getSharedPreferences();
  var lastSync = prefs.getString('lastSync');
  if (lastSync == null) {
    return null;
  }
  return DateTime.parse(lastSync).toLocal();
}
