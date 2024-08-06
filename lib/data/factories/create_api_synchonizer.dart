import 'package:get_it/get_it.dart';
import 'package:mala_front/data/factories/create_patient_repository.dart';
import 'package:mala_front/repositories/api_syncer.dart';
import 'package:mala_front/repositories/patient_repository/hybrid_patient_repository.dart';
import 'package:mala_front/usecase/error/get_error_message.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'http_client.dart';

Future<ApiSynchronizer?> createApiSynchonizer() async {
  var prefs = GetIt.I.get<SharedPreferences>();
  var rep = await createPatientRepository();
  if (rep is! HybridPatientRepository) {
    return null;
  }
  return ApiSynchronizer(
    hybridPatientRepository: rep,
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
