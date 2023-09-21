import 'package:mala_front/repositories/patient_api.dart';
import 'package:mala_front/usecase/patient/find_patient_by_remote_id.dart';
import 'package:mala_front/usecase/patient/upsert_patient.dart';
import 'package:mala_front/usecase/user/get_local_last_sync.dart';
import 'package:mala_front/usecase/user/update_last_sync.dart';
import 'package:vit/vit.dart';

import '../../../models/patient.dart';

Future<void> updatePatientsFromServer() async {
  var patientsRep = PatientApiRepository();
  var pageSize = 200;
  var currentPage = 0;
  Future<List<Patient>> fetch() async {
    var lastSync = getLocalLastSync();
    var newPatients = await patientsRep.getNewPatients(
      limit: pageSize,
      skip: (currentPage++) * pageSize,
      date: lastSync,
    );
    return newPatients;
  }

  while (true) {
    var patients = await fetch();
    logInfo('Found ${patients.length} to sync from server');
    if (patients.isEmpty) {
      break;
    }
    for (var patient in patients) {
      var remoteId = patient.remoteId!;
      var savedPatient = await findPatientByRemoteId(remoteId);
      if (savedPatient != null) {
        logInfo('Local patient found with same remote id when syncing with server');
        patient.id = savedPatient.id;
      }
      var pictureData = await patientsRep.getPicture(remoteId);
      await upsertPatient(
        patient,
        pictureData: pictureData,
        syncWithServer: false,
      );
    }
    var last = patients.last;
    var uploadedAt = last.uploadedAt!;
    await updateLastSync(uploadedAt);
  }
}
