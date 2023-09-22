import 'package:mala_front/factories/create_api_synchonizer.dart';

Future<void> sendFailedBackgroundOperations() async {
  var rep = createApiSynchonizer();
  await rep.retryFailedSyncronizations();
}
