import 'package:mala_front/factories/create_api_synchonizer.dart';

import '../../../../models/patient.dart';

/// Sends api call to send update or insert of new patient.
///
/// This method should NOT return a future, to prevent delays in the
/// UI.
Future<void> sendChangesInBackground(
  Patient patient, {
  bool throwOnError = false,
}) async {
  var rep = createApiSynchonizer();
  await rep.upsertPatient(
    patient,
    throwOnError: throwOnError,
  );
}
