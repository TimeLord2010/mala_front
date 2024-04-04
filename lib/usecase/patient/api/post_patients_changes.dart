import 'package:flutter/widgets.dart';
import 'package:mala_front/repositories/patient_api.dart';
import 'package:mala_front/usecase/patient/api/assign_remote_id_to_patient.dart';
import 'package:mala_front/usecase/patient/api/update_patients_from_server.dart';
import 'package:mala_front/usecase/patient/api/update_remote_patient_picture.dart';
import 'package:mala_front/usecase/patient/upsert_patient.dart';
import 'package:mala_front/usecase/user/update_last_sync.dart';

import '../../../models/patient.dart';

Future<void> postPatientsChanges({
  List<Patient>? changed,
  List<String>? deleted,
  bool updateFromServer = true,
  BuildContext? modalContext,
}) async {
  if (updateFromServer) {
    await updatePatientsFromServer(
      context: modalContext,
    );
  }
  var api = PatientApiRepository();
  var response = await api.postChanges(
    changed: changed,
    deleted: deleted,
  );
  if (changed == null) return;
  var insertedIds = response.changed?.inserted ?? [];
  var newPatients = changed.where((x) => x.remoteId == null);
  if (insertedIds.length != newPatients.length) {
    throw Exception('Api did respond with right number of inserted ids');
  }
  for (var i = 0; i < insertedIds.length; i++) {
    var remoteId = insertedIds[i];
    var patient = newPatients.elementAt(i);
    await assignRemoteIdToPatient(patient, remoteId);
    await updateRemotePatientPicture(patient);
  }
  var oldPatients = changed.where((x) => x.remoteId != null);
  for (var patient in oldPatients) {
    patient.uploadedAt = DateTime.now();
    await upsertPatient(
      patient,
      ignorePicture: true,
      syncWithServer: false,
      context: modalContext,
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
