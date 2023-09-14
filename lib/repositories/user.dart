import 'package:mala_front/factories/http_client.dart';
import 'package:mala_front/models/login_response.dart';

import '../models/user.dart';

class UserRepository {
  Future<LoginResponse> login(String email, String password) async {
    var response = await dio.get(
      '/user',
      queryParameters: {
        'email': email,
        'password': password,
      },
    );
    var user = User.fromMap(response.data);
    var jwt = response.headers.value('jwt');
    if (jwt == null) throw Exception('JWT not found at response headers');
    return LoginResponse(
      user: user,
      jwt: jwt,
    );
  }
}
