import 'dart:async';

import 'package:mala_front/data/entities/user.dart';
import 'package:mala_front/repositories/user.dart';
import 'package:mala_front/usecase/logs/insert_remote_log.dart';
import 'package:mala_front/usecase/user/update_jwt.dart';

Future<User> loginUser(String email, String password) async {
  var userRep = UserRepository();
  var response = await userRep.login(email, password);
  unawaited(insertRemoteLog(
    message: 'User logged in',
    context: 'login',
    extras: {'email': email},
  ));
  unawaited(updateJwt(response.jwt));
  return response.user;
}
