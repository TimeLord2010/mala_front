import 'package:mala_front/repositories/patient_api.dart';
import 'package:mala_front/usecase/patient/api/update_patients_from_server.dart';
import 'package:mala_front/usecase/patient/profile_picture/get_picture_file.dart';
import 'package:mala_front/usecase/patient/upsert_patient.dart';
import 'package:mala_front/usecase/user/update_last_sync.dart';

import '../../../models/patient.dart';

Future<void> postPatientsChanges({
  List<Patient>? changed,
  List<String>? deleted,
  bool updateFromServer = true,
}) async {
  if (updateFromServer) {
    await updatePatientsFromServer();
  }
  var rep = PatientApiRepository();
  var response = await rep.postChanges(
    changed: changed,
    deleted: deleted,
  );
  if (changed == null) return;
  var insertedIds = response.changed?.inserted ?? [];
  if (insertedIds.length != changed.length) {
    throw Exception('Api did respond with right number of inserted ids');
  }
  for (var i = 0; i < insertedIds.length; i++) {
    var remoteId = insertedIds[i];
    var patient = changed[i];
    patient.remoteId = remoteId;
    patient.uploadedAt = DateTime.now();
    await upsertPatient(patient);
    var file = await getPictureFile(patient.id);
    var exists = await file.exists();
    if (exists) {
      await rep.updatePicture(
        patientId: remoteId,
        file: file,
      );
    } else {
      await rep.deletePicture(
        patientId: remoteId,
      );
    }
  }
  if (changed.isNotEmpty) {
    var last = changed.last;
    var uploadedAt = last.uploadedAt!;
    await updateLastSync(uploadedAt);
  }
}
