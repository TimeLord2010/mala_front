import 'dart:async';

import 'package:mala_front/data/api_responses/get_patient_changes_response.dart';
import 'package:mala_front/data/entities/patient.dart';
import 'package:mala_front/data/entities/patient_query.dart';
import 'package:mala_front/data/factories/logger.dart';
import 'package:mala_front/data/interfaces/patient_interface.dart';
import 'package:mala_front/repositories/patient_api.dart';
import 'package:mala_front/repositories/patient_repository/local_patient_repository.dart';
import 'package:mala_front/repositories/patient_repository/online_patient_repository.dart';
import 'package:mala_front/repositories/stop_watch_events.dart';
import 'package:mala_front/usecase/error/get_error_message.dart';
import 'package:mala_front/usecase/local_store/get_local_last_sync.dart';
import 'package:mala_front/usecase/local_store/update_local_last_sync.dart';
import 'package:mala_front/usecase/logs/insert_remote_log.dart';
import 'package:mala_front/usecase/number/average.dart';
import 'package:mala_front/usecase/patient/api/post_patients_changes.dart';
import 'package:mala_front/usecase/patient/upsert_patient.dart';
import 'package:mala_front/usecase/user/update_last_sync.dart';

class HybridPatientRepository extends PatientInterface<String> {
  final LocalPatientRepository localRepository;
  final OnlinePatientRepository onlineRepository;

  HybridPatientRepository({
    required this.localRepository,
    required this.onlineRepository,
  });

  @override
  Future<int> count([PatientQuery? query]) {
    return localRepository.count(query);
  }

  @override
  Future<void> delete(Patient patient) async {
    await onlineRepository.delete(patient);
    await localRepository.delete(patient);
  }

  @override
  Future<Iterable<Patient>> list(
    PatientQuery query, {
    int? skip,
    int? limit,
  }) {
    return localRepository.list(
      query,
      skip: skip,
      limit: limit,
    );
  }

  @override
  Future<Patient> upsert(Patient patient) async {
    var localPatient = await localRepository.upsert(patient);
    var remotePatient = await onlineRepository.upsert(localPatient);
    return remotePatient;
  }

  Future<void> sendAllToApi() async {
    var limit = 100;
    while (true) {
      var patients = await localRepository.findLocalPatients(skip: 0, limit: limit);
      if (patients.isEmpty) break;
      await postPatientsChanges(
        changed: patients,
        updateFromServer: false,
        modalContext: null,
      );
      unawaited(insertRemoteLog(
        message: 'Sending ${patients.length} local patients',
        context: 'Send local patients to server',
        extras: {
          'creationDates': patients.map((x) => x.createdAt).toList(),
        },
      ));
    }
  }

  Future<void> updatePatientsFromServer({
    void Function(String? lastSync)? updater,
    bool Function()? didCancel,
  }) async {
    var begin = DateTime.now();
    var pageSize = 150;

    final count = await localRepository.count();
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
        var patientsRep = PatientApiRepository();
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
          var localId = await localRepository.findIdByRemoteId(remoteId);
          if (localId != null) {
            logger.warn('Local patient found with same remote id when syncing');
            patient.id = localId;
          }
          await upsertPatient(
            patient,
            syncWithServer: false,
            ignorePicture: true,
            context: null,
          );
          setLastServerDate(patient.uploadedAt!);
        }
        for (var deleteRecord in response.deleted) {
          for (var patientRemoteId in deleteRecord.patientIds) {
            var localId = await localRepository.findIdByRemoteId(patientRemoteId);
            if (localId == null) {
              logger.warn('Did not found patient to delete: $patientRemoteId');
              continue;
            }
            await localRepository.deleteById(localId);
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

  @override
  Future<Iterable<Patient>> listByCreation(Iterable<DateTime> createdAts) {
    return localRepository.listByCreation(createdAts);
  }

  @override
  Future<Patient?> getById(String id) {
    var parsedId = localRepository.getId(id);
    return localRepository.getById(parsedId);
  }

  @override
  Future<void> deleteById(String id) async {
    var localId = localRepository.getId(id);
    await localRepository.deleteById(localId);
    await onlineRepository.deleteById(id);
  }
}
