import 'package:get_it/get_it.dart';
import 'package:mala_front/repositories/api_syncer.dart';
import 'package:mala_front/usecase/error/get_error_message.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'http_client.dart';

ApiSynchronizer createApiSynchonizer() {
  var prefs = GetIt.I.get<SharedPreferences>();
  return ApiSynchronizer(
    preferences: prefs,
    errorReporter: (context, err) async {
      await dio.post(
        '/log',
        data: {
          'context': 'context',
          'level': 'error',
          'message': getErrorMessage(err) ?? '<no message found>',
        },
      );
    },
  );
}
