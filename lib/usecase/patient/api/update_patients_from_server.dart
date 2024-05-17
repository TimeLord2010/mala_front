import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:mala_front/factories/logger.dart';
import 'package:mala_front/models/api_responses/get_patient_changes_response.dart';
import 'package:mala_front/repositories/patient_api.dart';
import 'package:mala_front/repositories/stop_watch_events.dart';
import 'package:mala_front/usecase/error/get_error_message.dart';
import 'package:mala_front/usecase/local_store/update_local_last_sync.dart';
import 'package:mala_front/usecase/logs/insert_remote_log.dart';
import 'package:mala_front/usecase/patient/count_all_patients.dart';
import 'package:mala_front/usecase/patient/delete_patient.dart';
import 'package:mala_front/usecase/patient/find_patient_by_remote_id.dart';
import 'package:mala_front/usecase/patient/upsert_patient.dart';
import 'package:mala_front/usecase/user/update_last_sync.dart';

import '../../local_store/get_local_last_sync.dart';
import '../../number/average.dart';

Future<void> updatePatientsFromServer({
  BuildContext? context,
  void Function(String? lastSync)? updater,
  bool Function()? didCancel,
}) async {
  var begin = DateTime.now();
  var patientsRep = PatientApiRepository();
  var pageSize = 150;

  final count = await countAllPatients();
  if (count == 0) {
    // Resetando a data para o inicio da aplicação para pegar todos os registros
    await updateLocalLastSync(DateTime(2020));
  }

  var scannedDates = <DateTime>{};
  var eventTimes = StopWatchEvents();

  Future<GetPatientChangesResponse> fetch() async {
    var lastSync = getLocalLastSync() ?? DateTime(2020);
    if (scannedDates.contains(lastSync)) {
      throw Exception('Tried to scan the same date: ${lastSync.toIso8601String()}');
    }
    scannedDates.add(lastSync);
    logger.info('Last sync: ${lastSync.toIso8601String()}.');
    var newPatients = await eventTimes.add(() async {
      return await patientsRep
          .getServerChanges(
            limit: pageSize,
            skip: 0,
            date: lastSync,
          )
          .timeout(const Duration(seconds: 6));
    });
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

  Map<String, dynamic> getExtras() {
    var inMilli = eventTimes.inMilli;
    return {
      'lastServerDate': lastServerDate?.toIso8601String(),
      'ApiDelays': inMilli,
      'ApiDelayAvg': average(inMilli),
      'elapsed': '${DateTime.now().difference(begin).inSeconds}s',
    };
  }

  try {
    while (true) {
      if (didCancel != null && didCancel()) {
        break;
      }
      var response = await fetch();
      logger.info('Found ${response.length} to sync from server');
      if (response.isEmpty) {
        break;
      }
      for (var patient in response.changed) {
        var remoteId = patient.remoteId!;
        var localId = await findPatientByRemoteId(remoteId);
        if (localId != null) {
          logger.warn('Local patient found with same remote id when syncing');
          patient.id = localId;
        }
        await upsertPatient(
          patient,
          syncWithServer: false,
          ignorePicture: true,
          context: context,
        );
        setLastServerDate(patient.uploadedAt!);
      }
      for (var deleteRecord in response.deleted) {
        for (var patientRemoteId in deleteRecord.patientIds) {
          var localId = await findPatientByRemoteId(patientRemoteId);
          if (localId == null) {
            logger.warn('Did not found patient to delete: $patientRemoteId');
            continue;
          }
          await deletePatient(
            localId,
            context: context,
          );
        }
        // setLastServerDate(deleteRecord.disabledAt);
      }
      // if (response.changed.isEmpty) {
      //   if (response.deleted.isEmpty) {
      //     break;
      //   } else {
      //     var last = response.deleted.last;
      //     setLastServerDate(last.disabledAt);
      //     await updateSavedLastSync();
      //   }
      // } else {
      //   await updateSavedLastSync();
      // }
      await updateSavedLastSync();
      if (didCancel != null) {
        if (!didCancel()) updater?.call(lastServerDate?.toIso8601String());
      } else {
        updater?.call(lastServerDate?.toIso8601String());
      }
      if (response.length < pageSize) {
        break;
      }
    }
    unawaited(insertRemoteLog(
      message: 'Finished syncing',
      context: 'Sync patients',
      extras: getExtras(),
    ));
  } catch (e) {
    var msg = getErrorMessage(e) ?? '?';
    unawaited(insertRemoteLog(
      message: msg,
      context: 'Sync patients',
      extras: getExtras(),
    ));
    rethrow;
  } finally {
    await updateSavedLastSync();
  }
}
