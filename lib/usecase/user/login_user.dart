import 'package:mala_front/models/user.dart';
import 'package:mala_front/repositories/user.dart';
import 'package:vit/vit.dart';

Future<User> loginUser(String email, String password) async {
  var userRep = UserRepository();
  var response = await userRep.login(email, password);
  var sharedPreferences = Vit().getSharedPreferences();
  await sharedPreferences.setString('jwt', response.jwt);
  return response.user;
}
