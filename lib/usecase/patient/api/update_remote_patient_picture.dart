import 'package:mala_front/data/entities/patient.dart';
import 'package:mala_front/data/models/features.dart';
import 'package:mala_front/repositories/patient_api.dart';

import '../profile_picture/get_picture_file.dart';

Future<void> updateRemotePatientPicture(Patient patient) async {
  if (!Features.imageSuport) {
    return;
  }
  var api = PatientApiRepository();
  var remoteId = patient.remoteId;
  if (remoteId == null) {
    throw Exception('Não é possível atualizar foto de patiente no servidor sem um identificador.');
  }
  var file = await getPictureFile(patient.id);
  var exists = file.existsSync();
  if (exists) {
    await api.updatePicture(
      patientId: remoteId,
      file: file,
    );
  } else {
    await api.deletePicture(
      patientId: remoteId,
    );
  }
}
