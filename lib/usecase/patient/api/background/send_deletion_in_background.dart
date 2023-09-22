import '../../../../factories/create_api_synchonizer.dart';

void sendDeletionInBackground(String patientId) async {
  var rep = createApiSynchonizer();
  await rep.deletePatient(patientId);
}
