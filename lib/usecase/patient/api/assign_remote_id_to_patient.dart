import 'package:mala_front/models/patient.dart';

import '../upsert_patient.dart';

Future<void> assignRemoteIdToPatient(Patient patient, String remoteId) async {
  patient.remoteId = remoteId;
  patient.uploadedAt = DateTime.now();
  await upsertPatient(
    patient,
    ignorePicture: true,
    syncWithServer: false,
  );
}
