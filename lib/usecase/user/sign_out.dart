import '../../factories/http_client.dart';
import 'update_jwt.dart';

Future<void> signout() async {
  dio.options.headers.clear();
  await updateJwt(null);
}
