import 'package:mala_front/repositories/patient_api.dart';
import 'package:mala_front/usecase/patient/upsert_patient.dart';
import 'package:mala_front/usecase/user/update_last_sync.dart';

import '../../../models/patient.dart';

Future<void> updatePatientsFromServer() async {
  var patientsRep = PatientApiRepository();
  var pageSize = 200;
  var currentPage = 0;
  Future<List<Patient>> fetch() async {
    var newPatients = await patientsRep.getNewPatients(
      limit: pageSize,
      skip: (currentPage++) * pageSize,
    );
    return newPatients;
  }

  while (true) {
    var patients = await fetch();
    if (patients.isEmpty) {
      break;
    }
    for (var patient in patients) {
      await upsertPatient(patient);
    }
    var last = patients.last;
    var uploadedAt = last.uploadedAt!;
    await updateLastSync(uploadedAt);
  }
}
