import 'package:mala_front/data/factories/create_api_synchonizer.dart';

Future<void> sendFailedBackgroundOperations() async {
  var rep = await createApiSynchonizer();
  if (rep == null) {
    return;
  }
  await rep.retryFailedSyncronizations();
}
