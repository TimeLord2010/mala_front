import 'package:mala_front/repositories/user.dart';
import 'package:mala_front/usecase/local_store/update_local_last_sync.dart';

Future<void> updateLastSync(DateTime date) async {
  var rep = UserRepository();
  await rep.updateLastSync(date);
  await updateLocalLastSync(date);
}
