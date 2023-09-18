import 'dart:typed_data';

import 'package:mala_front/factories/patient_repository.dart';
import 'package:mala_front/models/patient.dart';
import 'package:mala_front/usecase/patient/profile_picture/save_or_remove_profile_picture.dart';
import 'package:vit/vit.dart';

Future<Patient> upsertPatient(
  Patient patient, {
  Uint8List? pictureData,
}) async {
  var stopWatch = StopWatch('upsertPatient');
  var rep = await createPatientRepository();
  stopWatch.lap(tag: 'connect');
  var result = await rep.insert(patient);
  await saveOrRemoveProfilePicture(
    patientId: result.id,
    data: pictureData,
  );
  stopWatch.stop();
  return result;
}
