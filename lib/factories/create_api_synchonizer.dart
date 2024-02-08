import 'package:mala_front/repositories/api_syncer.dart';
import 'package:mala_front/usecase/error/get_error_message.dart';
import 'package:vit/vit.dart' as vit;

import 'http_client.dart';

ApiSynchronizer createApiSynchonizer() {
  var prefs = vit.Vit().getSharedPreferences();
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
