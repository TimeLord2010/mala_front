import 'package:vit/vit.dart';

import '../../factories/http_client.dart';

Future<void> signout() async {
  dio.options.headers.clear();
  await Vit().getSharedPreferences().clear();
}
