import 'dart:async';

import 'package:mala_front/data/entities/patient.dart';
import 'package:mala_front/data/enums/local_keys.dart';
import 'package:mala_front/data/factories/logger.dart';
import 'package:mala_front/usecase/error/get_error_message.dart';
import 'package:mala_front/usecase/patient/api/post_patients_changes.dart';
import 'package:mala_front/usecase/patient/find_patient_by_id.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      logger.info('Sending pending deletion: $patient');
      await deletePatient(patient);
      await Future.delayed(const Duration(milliseconds: 500));
    }

    var pendingUpdate = preferences.getStringList(_updateKey) ?? [];
    for (var patientId in pendingUpdate) {
      var id = int.parse(patientId);
      logger.info('Sending pending upsert: $id');
      var patient = await findPatientById(id.toString());
      if (patient == null) continue;
      await upsertPatient(patient);
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  /// This function will never throw an exception.
  ///
  /// Use [errorReporter] to catch exceptions instead.
  Future<void> upsertPatient(
    Patient patient, {
    bool throwOnError = false,
  }) async {
    var isLocal = patient.remoteId == null;
    return _sendChangeToServer(
      entityId: patient.id.toString(),
      key: isLocal ? null : _updateKey,
      throwOnError: throwOnError,
      function: () async {
        await postPatientsChanges(
          changed: [patient],
        );
      },
    );
  }

  Future<void> deletePatient(
    String patientId, {
    bool throwOnError = false,
  }) {
    return _sendChangeToServer(
      entityId: patientId,
      key: _deleteKey,
      throwOnError: throwOnError,
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
    bool throwOnError = false,
  }) async {
    if (key != null) await _insertKey(entityId: entityId, key: key);
    try {
      await function();
      if (key != null) await _removeKey(entityId: entityId, key: key);
    } catch (error, stack) {
      logger.error(stack.toString());
      try {
        if (key != null) {
          await errorReporter(key, error);
        } else {
          await errorReporter(entityId.toString(), error);
        }
      } catch (e) {
        logger.error('Failed to report error from api sync: ${getErrorMessage(e)}');
      }
      if (throwOnError) rethrow;
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
