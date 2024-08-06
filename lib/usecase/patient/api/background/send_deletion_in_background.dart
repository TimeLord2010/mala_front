import '../../../../data/factories/create_api_synchonizer.dart';

/// Notifies the backend that the patient was deleted.
///
/// If the operation fails for any reason, such as no internet connection, the
/// operation is saved in memory to be retried later.
Future<void> sendDeletionInBackground(
  String patientId, {
  bool throwOnError = false,
}) async {
  var rep = await createApiSynchonizer();
  if (rep == null) {
    return;
  }
  await rep.deletePatient(
    patientId,
    throwOnError: throwOnError,
  );
}
