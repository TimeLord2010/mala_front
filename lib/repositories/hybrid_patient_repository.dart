import 'dart:async';

import 'package:mala_front/data/api_responses/get_patient_changes_response.dart';
import 'package:mala_front/data/entities/patient.dart';
import 'package:mala_front/data/entities/patient_query.dart';
import 'package:mala_front/data/factories/logger.dart';
import 'package:mala_front/data/interfaces/patient_interface.dart';
import 'package:mala_front/repositories/local_patient_repository.dart';
import 'package:mala_front/repositories/patient_api.dart';
import 'package:mala_front/repositories/stop_watch_events.dart';
import 'package:mala_front/usecase/error/get_error_message.dart';
import 'package:mala_front/usecase/local_store/get_local_last_sync.dart';
import 'package:mala_front/usecase/local_store/update_local_last_sync.dart';
import 'package:mala_front/usecase/logs/insert_remote_log.dart';
import 'package:mala_front/usecase/number/average.dart';
import 'package:mala_front/usecase/patient/api/assign_remote_id_to_patient.dart';
import 'package:mala_front/usecase/patient/api/post_patients_changes.dart';
import 'package:mala_front/usecase/patient/api/update_remote_patient_picture.dart';
import 'package:mala_front/usecase/patient/count_all_patients.dart';
import 'package:mala_front/usecase/patient/delete_patient.dart';
import 'package:mala_front/usecase/patient/find_patient_by_remote_id.dart';
import 'package:mala_front/usecase/patient/upsert_patient.dart';
import 'package:mala_front/usecase/user/update_last_sync.dart';

class HybridPatientRepository extends PatientInterface {
  final LocalPatientRepository localRepository;

  HybridPatientRepository({
    required this.localRepository,
  });

  @override
  Future<int> count([PatientQuery? query]) {
    return localRepository.count(query);
  }

  @override
  Future<void> delete(Patient patient) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future<Iterable<Patient>> list(PatientQuery query, {int? skip, int? limit}) {
    // TODO: implement list
    throw UnimplementedError();
  }

  @override
  Future<Patient> upsert(Patient patient) {
    // TODO: implement upsert
    throw UnimplementedError();
  }

  Future<void> sendAllToApi() async {
    var limit = 100;
    while (true) {
      var patients = await localRepository.findLocalPatients(skip: 0, limit: limit);
      if (patients.isEmpty) break;
      await postPatientsChanges(
        changed: patients,
        updateFromServer: false,
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
      for (DeletedUsersRecord deleteRecord in response.deleted) {
        for (String patientRemoteId in deleteRecord.patientIds) {
          var localId = await localRepository.findIdByRemoteId(patientRemoteId);
          if (localId == null) {
            logger.warn('Did not found patient to delete: $patientRemoteId');
            continue;
          }
          await deletePatient(
            localId.toString(), context: null,
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

Future<void> postPatientsChanges({
  List<Patient>? changed,
  List<String>? deleted,
  bool updateFromServer = true,
}) async {
  if (updateFromServer) {
    await updatePatientsFromServer(
    );
  }
  var api = PatientApiRepository();
  var response = await api.postChanges(
    changed: changed,
    deleted: deleted,
  );
  if (changed == null) return;
  var insertedIds = response.changed?.inserted ?? [];
  List<Patient> newPatients = changed.where((x) => x.remoteId == null).toList();
  if (insertedIds.length != newPatients.length) {
    throw Exception('Api did respond with right number of inserted ids');
  }
  for (var i = 0; i < insertedIds.length; i++) {
    var remoteId = insertedIds[i];
    var patient = newPatients[i];
    await assignRemoteIdToPatient(patient, remoteId);
    if (patient.hasPicture == true) {
      await updateRemotePatientPicture(patient);
    }
  }
  var oldPatients = changed.where((x) => x.remoteId != null);
  for (var patient in oldPatients) {
    patient.uploadedAt = DateTime.now();
    await upsertPatient(
      patient,
      ignorePicture: true,
      syncWithServer: false,
      context: null,
    );
    await updateRemotePatientPicture(patient);
  }
  if (changed.isNotEmpty) {
    var last = changed.lastWhere(
      (x) => x.uploadedAt != null,
      orElse: () => Patient(),
    );
    if (last.isEmpty) {
      return;
    }
    var uploadedAt = last.uploadedAt!;
    await updateLastSync(uploadedAt);
  }
}

  @override
  Future<Patient> getById(String id) {
    // TODO: implement getById
    throw UnimplementedError();
  }

  @override
  Future<Iterable<Patient>> listByCreation({required Iterable<DateTime> createdAts}) {
    // TODO: implement listByCreation
    throw UnimplementedError();
  }
}
