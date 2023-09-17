import 'package:mala_front/repositories/user.dart';

Future<void> updateLastSync(DateTime date) async {
  var rep = UserRepository();
  await rep.updateLastSync(date);
}
