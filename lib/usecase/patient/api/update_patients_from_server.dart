import 'dart:typed_data';

import 'package:mala_front/models/api_responses/get_patient_changes_response.dart';
import 'package:mala_front/repositories/patient_api.dart';
import 'package:mala_front/usecase/local_store/update_local_last_sync.dart';
import 'package:mala_front/usecase/patient/count_all_patients.dart';
import 'package:mala_front/usecase/patient/delete_patient.dart';
import 'package:mala_front/usecase/patient/find_patient_by_remote_id.dart';
import 'package:mala_front/usecase/patient/upsert_patient.dart';
import 'package:mala_front/usecase/user/update_last_sync.dart';
import 'package:vit/vit.dart';

import '../../local_store/get_local_last_sync.dart';

Future<void> updatePatientsFromServer({
  void Function(String? lastSync)? updater,
  bool Function()? didCancel,
}) async {
  var patientsRep = PatientApiRepository();
  var pageSize = 150;
  // var currentPage = 0;

  final count = await countAllPatients();
  if (count == 0) {
    // Resetando a data para o inicio da aplicação para pegar todos os registros
    await updateLocalLastSync(DateTime(2020));
  }

  Future<GetPatientChangesResponse> fetch() async {
    var lastSync = getLocalLastSync() ?? DateTime(2020);
    // var skip = (currentPage++) * pageSize;
    logInfo('Last sync: ${lastSync.toIso8601String()}.');
    var newPatients = await patientsRep
        .getServerChanges(
          limit: pageSize,
          skip: 0,
          date: lastSync,
        )
        .timeout(const Duration(seconds: 6));
    return newPatients;
  }

  DateTime? lastServerDate;
  void setLastServerDate(DateTime dt) {
    if (lastServerDate == null) {
      lastServerDate = dt;
      return;
    }
    if (dt.isAfter(lastServerDate!) || dt.millisecondsSinceEpoch == lastServerDate!.millisecondsSinceEpoch) {
      lastServerDate = dt;
    }
  }

  Future<void> updateSavedLastSync() async {
    if (didCancel != null && didCancel()) {
      return;
    }
    if (lastServerDate != null) {
      await updateLastSync(lastServerDate!);
    }
  }

  try {
    while (true) {
      if (didCancel != null && didCancel()) {
        break;
      }
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
        Uint8List? pictureData;
        if (patient.hasPicture == null || patient.hasPicture == true) {
          pictureData = await patientsRep.getPicture(remoteId);
        }
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
        // setLastServerDate(deleteRecord.disabledAt);
      }
      if (response.changed.isEmpty) {
        if (response.deleted.isEmpty) {
          break;
        } else {
          var last = response.deleted.last;
          setLastServerDate(last.disabledAt);
          await updateSavedLastSync();
        }
      } else {
        await updateSavedLastSync();
      }
      if (didCancel != null) {
        if (!didCancel()) updater?.call(lastServerDate?.toIso8601String());
      } else {
        updater?.call(lastServerDate?.toIso8601String());
      }
      if (response.length < pageSize) {
        break;
      }
    }
  } finally {
    await updateSavedLastSync();
  }
}
