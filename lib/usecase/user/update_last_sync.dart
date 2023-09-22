import 'package:mala_front/models/enums/local_keys.dart';
import 'package:mala_front/repositories/user.dart';
import 'package:vit/vit.dart';

Future<void> updateLastSync(DateTime date) async {
  var rep = UserRepository();
  await rep.updateLastSync(date);
  var preferences = Vit().getSharedPreferences();
  var value = date.toIso8601String();
  await preferences.setString(LocalKeys.lastSync.name, value);
}
