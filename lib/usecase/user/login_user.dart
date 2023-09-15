import 'package:mala_front/models/user.dart';
import 'package:mala_front/repositories/user.dart';
import 'package:mala_front/usecase/user/update_jwt.dart';

Future<User> loginUser(String email, String password) async {
  var userRep = UserRepository();
  var response = await userRep.login(email, password);
  updateJwt(response.jwt);
  return response.user;
}
