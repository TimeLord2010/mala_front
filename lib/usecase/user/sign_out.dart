import 'package:flutter/foundation.dart';

import '../../factories/http_client.dart';
import 'update_jwt.dart';

Future<void> signout() async {
  // if (kDebugMode) {
  //   //await deleteUserFiles();
  // } else {
  // }
  await updateJwt(null);
}
