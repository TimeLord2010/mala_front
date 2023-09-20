import 'dart:typed_data';

import 'package:mala_front/factories/patient_repository.dart';
import 'package:mala_front/models/patient.dart';
import 'package:mala_front/usecase/patient/api/post_patients_changes.dart';
import 'package:mala_front/usecase/patient/profile_picture/save_or_remove_profile_picture.dart';
import 'package:vit/vit.dart';

Future<Patient> upsertPatient(
  Patient patient, {
  Uint8List? pictureData,
  bool syncWithServer = true,
}) async {
  var stopWatch = StopWatch('upsertPatient');
  var rep = await createPatientRepository();
  var result = await rep.insert(patient);
  await saveOrRemoveProfilePicture(
    patientId: result.id,
    data: pictureData,
  );
  if (syncWithServer) {
    stopWatch.lap(tag: 'local done');
    var remoteId = patient.remoteId;
    if (remoteId == null) {
      await postPatientsChanges(
        changed: [patient],
      );
    }
  }
  stopWatch.stop();
  return result;
}
