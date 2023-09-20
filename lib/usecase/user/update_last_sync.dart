import 'package:mala_front/repositories/user.dart';
import 'package:vit/vit.dart';

Future<void> updateLastSync(DateTime date) async {
  var rep = UserRepository();
  await rep.updateLastSync(date);
  var sharedPreferences = Vit().getSharedPreferences();
  await sharedPreferences.setString('lastSync', date.toIso8601String());
}
