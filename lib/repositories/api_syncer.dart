import 'dart:async';

import 'package:mala_front/models/enums/local_keys.dart';
import 'package:mala_front/models/patient.dart';
import 'package:mala_front/usecase/error/get_error_message.dart';
import 'package:mala_front/usecase/patient/api/post_patients_changes.dart';
import 'package:mala_front/usecase/patient/find_patient_by_id.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vit/vit.dart' as vit;

class ApiSynchronizer {
  final SharedPreferences preferences;
  final FutureOr<void> Function(String context, Object error) errorReporter;

  ApiSynchronizer({
    required this.preferences,
    required this.errorReporter,
  });

  Future<void> retryFailedSyncronizations() async {
    var pendingDeletion = preferences.getStringList(_deleteKey) ?? [];
    for (var patient in pendingDeletion) {
      vit.logInfo('Sending pending deletion: $patient');
      await deletePatient(patient);
      await Future.delayed(const Duration(milliseconds: 500));
    }

    var pendingUpdate = preferences.getStringList(_updateKey) ?? [];
    for (var patientId in pendingUpdate) {
      var id = int.parse(patientId);
      vit.logInfo('Sending pending upsert: $id');
      var patient = await findPatientById(id);
      if (patient == null) continue;
      await upsertPatient(patient);
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  Future<void> upsertPatient(Patient patient) async {
    var isLocal = patient.remoteId == null;
    return _sendChangeToServer(
      entityId: patient.id.toString(),
      key: isLocal ? null : _updateKey,
      function: () async {
        await postPatientsChanges(
          changed: [patient],
        );
      },
    );
  }

  Future<void> deletePatient(String patientId) {
    return _sendChangeToServer(
      entityId: patientId,
      key: _deleteKey,
      function: () async {
        await postPatientsChanges(
          deleted: [patientId],
        );
      },
    );
  }

  // TODO: Run in isolate
  Future<void> _sendChangeToServer({
    required String entityId,
    required String? key,
    required Future<void> Function() function,
  }) async {
    if (key != null) await _insertKey(entityId: entityId, key: key);
    try {
      await function();
      if (key != null) await _removeKey(entityId: entityId, key: key);
    } catch (error) {
      try {
        if (key != null) {
          await errorReporter(key, error);
        } else {
          await errorReporter(entityId.toString(), error);
        }
      } catch (e) {
        vit.logError('Failed to report error from api sync: ${getErrorMessage(e)}');
      }
    }
  }

  Future<void> _insertKey({
    required String entityId,
    required String key,
  }) async {
    var value = preferences.getStringList(key) ?? [];
    value.add(entityId);
    await preferences.setStringList(key, value.toSet().toList());
  }

  Future<void> _removeKey({
    required String entityId,
    required String key,
  }) async {
    var list = preferences.getStringList(key) ?? [];
    list.remove(entityId);
    await preferences.setStringList(key, list);
  }
}

String _deleteKey = LocalKeys.pendingPatientsDeletion.name;
String _updateKey = LocalKeys.pendingPatientsUpdate.name;
