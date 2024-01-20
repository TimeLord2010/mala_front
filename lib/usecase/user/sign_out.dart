import 'package:mala_front/usecase/user/update_last_sync.dart';

import 'update_jwt.dart';

Future<void> signout() async {
  // if (kDebugMode) {
  //   //await deleteUserFiles();
  // } else {
  // }
  await updateLastSync(DateTime(2020));
  await updateJwt(null);
}
