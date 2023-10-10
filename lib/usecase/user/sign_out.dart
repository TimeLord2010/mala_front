import 'update_jwt.dart';

Future<void> signout() async {
  // if (kDebugMode) {
  //   //await deleteUserFiles();
  // } else {
  // }
  await updateJwt(null);
}
