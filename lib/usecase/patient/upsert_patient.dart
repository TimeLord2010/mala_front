import 'dart:typed_data';

import 'package:mala_front/factories/patient_repository.dart';
import 'package:mala_front/models/patient.dart';
import 'package:mala_front/usecase/patient/api/background/send_changes_in_background.dart';
import 'package:mala_front/usecase/patient/profile_picture/save_or_remove_profile_picture.dart';
import 'package:vit/vit.dart';

Future<Patient> upsertPatient(
  Patient patient, {
  Uint8List? pictureData,
  bool syncWithServer = true,
  bool ignorePicture = false,
}) async {
  var stopWatch = StopWatch('upsertPatient');
  var rep = await createPatientRepository();
  var result = await rep.insert(patient);
  if (!ignorePicture) {
    await saveOrRemoveProfilePicture(
      patientId: result.id,
      data: pictureData,
    );
  }
  if (syncWithServer) {
    stopWatch.lap(tag: 'local done');
    sendChangesInBackground(patient);
    // await postPatientsChanges(
    //   changed: [patient],
    // );
  }
  stopWatch.stop();
  return result;
}
