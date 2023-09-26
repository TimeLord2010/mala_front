import 'package:mala_front/factories/patient_repository.dart';
import 'package:mala_front/usecase/patient/api/background/send_deletion_in_background.dart';
import 'package:mala_front/usecase/patient/find_patient_by_id.dart';
import 'package:vit/vit.dart';

Future<void> deletePatient(
  int patientId, {
  bool sendDeletionToServer = true,
}) async {
  var stopWatch = StopWatch('deletePatient');
  try {
    var rep = await createPatientRepository();
    var patient = await findPatientById(patientId);
    if (patient == null) {
      return;
    }
    var remoteId = patient.remoteId;
    if (remoteId != null && sendDeletionToServer) {
      sendDeletionInBackground(remoteId);
      // await postPatientsChanges(
      //   deleted: [remoteId],
      // );
    }
    await rep.delete(patientId);
  } finally {
    stopWatch.stop();
  }
}
