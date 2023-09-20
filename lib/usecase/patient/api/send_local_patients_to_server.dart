import 'package:mala_front/factories/patient_repository.dart';
import 'package:mala_front/usecase/patient/api/post_patients_changes.dart';

Future<void> sendLocalPatientsToServer() async {
  var patientsRep = await createPatientRepository();
  var limit = 100;
  while (true) {
    var patients = await patientsRep.findLocalPatients(skip: 0, limit: limit);
    if (patients.isEmpty) break;
    await postPatientsChanges(
      changed: patients,
      updateFromServer: false,
    );
  }
}
