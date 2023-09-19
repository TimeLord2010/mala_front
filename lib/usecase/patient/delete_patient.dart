import 'package:mala_front/factories/patient_repository.dart';
import 'package:mala_front/usecase/patient/api/post_patients_changes.dart';
import 'package:mala_front/usecase/patient/get_patient_by_id.dart';
import 'package:vit/vit.dart';

Future<void> deletePatient(int patientId) async {
  var stopWatch = StopWatch('deletePatient');
  try {
    var rep = await createPatientRepository();
    var patient = await getPatientById(patientId);
    if (patient == null) {
      return;
    }
    var remoteId = patient.remoteId;
    if (remoteId != null) {
      await postPatientsChanges(
        deleted: [remoteId],
      );
    }
    await rep.delete(patientId);
  } finally {
    stopWatch.stop();
  }
}
