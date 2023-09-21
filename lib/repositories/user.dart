import 'package:mala_front/factories/http_client.dart';
import 'package:mala_front/models/api_responses/login_response.dart';
import 'package:vit/vit.dart';

import '../models/user.dart';

class UserRepository {
  Future<LoginResponse> login(String email, String password) async {
    var stopWatch = StopWatch('api:login');
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
    stopWatch.stop();
    return LoginResponse(
      user: user,
      jwt: jwt,
    );
  }

  Future<String> generateNewJwt() async {
    var stopWatch = StopWatch('api:generateNewJWT');
    try {
      var response = await dio.get('/user/self');
      String? jwt = response.headers.value('jwt');
      if (jwt == null) throw Exception('JWT not found at response headers');
      return jwt;
    } finally {
      stopWatch.stop();
    }
  }

  Future<void> updateLastSync(DateTime date) async {
    var iso = date.toUtc().toIso8601String();
    var stopWatch = StopWatch('api:updateLastSync ($iso)');
    await dio.post(
      '/user',
      data: {
        'lastSyncDate': iso,
      },
    );
    stopWatch.stop();
  }
}
