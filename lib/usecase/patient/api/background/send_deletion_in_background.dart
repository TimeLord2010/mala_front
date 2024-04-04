import '../../../../factories/create_api_synchonizer.dart';

Future<void> sendDeletionInBackground(
  String patientId, {
  bool throwOnError = false,
}) async {
  var rep = createApiSynchonizer();
  await rep.deletePatient(
    patientId,
    throwOnError: throwOnError,
  );
}
