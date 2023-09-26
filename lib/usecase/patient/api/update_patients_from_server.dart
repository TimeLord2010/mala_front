import 'package:mala_front/models/api_responses/get_patient_changes_response.dart';
import 'package:mala_front/repositories/patient_api.dart';
import 'package:mala_front/usecase/patient/delete_patient.dart';
import 'package:mala_front/usecase/patient/find_patient_by_remote_id.dart';
import 'package:mala_front/usecase/patient/upsert_patient.dart';
import 'package:mala_front/usecase/user/get_local_last_sync.dart';
import 'package:mala_front/usecase/user/update_last_sync.dart';
import 'package:vit/vit.dart';

Future<void> updatePatientsFromServer() async {
  var patientsRep = PatientApiRepository();
  var pageSize = 200;
  var currentPage = 0;
  Future<GetPatientChangesResponse> fetch() async {
    var lastSync = getLocalLastSync() ?? DateTime(2020);
    var newPatients = await patientsRep.getServerChanges(
      limit: pageSize,
      skip: (currentPage++) * pageSize,
      date: lastSync,
    );
    return newPatients;
  }

  DateTime? lastServerDate;
  void setLastServerDate(DateTime dt) {
    if (lastServerDate == null) {
      lastServerDate = dt;
      return;
    }
    if (dt.isAfter(lastServerDate!)) {
      lastServerDate = dt;
    }
  }

  try {
    while (true) {
      var response = await fetch();
      logInfo('Found ${response.length} to sync from server');
      if (response.isEmpty) {
        break;
      }
      for (var patient in response.changed) {
        var remoteId = patient.remoteId!;
        var savedPatient = await findPatientByRemoteId(remoteId);
        if (savedPatient != null) {
          logWarn('Local patient found with same remote id when syncing with server');
          patient.id = savedPatient.id;
        }
        var pictureData = await patientsRep.getPicture(remoteId);
        await upsertPatient(
          patient,
          pictureData: pictureData,
          syncWithServer: false,
        );
        setLastServerDate(patient.uploadedAt!);
      }
      for (var deleteRecord in response.deleted) {
        for (var patientRemoteId in deleteRecord.patientIds) {
          var patient = await findPatientByRemoteId(patientRemoteId);
          if (patient == null) {
            logWarn('Did not found patient to delete: $patientRemoteId');
            continue;
          }
          await deletePatient(
            patient.id,
            sendDeletionToServer: false,
          );
        }
        setLastServerDate(deleteRecord.disabledAt);
      }
    }
  } finally {
    if (lastServerDate != null) {
      await updateLastSync(lastServerDate!);
    }
  }
}
