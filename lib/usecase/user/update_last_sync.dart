import 'package:dio/dio.dart';
import 'package:mala_front/repositories/user.dart';
import 'package:mala_front/usecase/error/is_no_internet_error.dart';
import 'package:mala_front/usecase/local_store/update_local_last_sync.dart';

Future<void> updateLastSync(DateTime date) async {
  try {
    var rep = UserRepository();
    await rep.updateLastSync(date);
  } on DioException catch (e) {
    if (!isNoInternetError(e)) {
      rethrow;
    }
  }
  await updateLocalLastSync(date);
}
