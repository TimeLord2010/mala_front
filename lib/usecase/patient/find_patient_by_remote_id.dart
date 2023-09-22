import 'package:mala_front/factories/patient_repository.dart';

import '../../models/patient.dart';

Future<Patient?> findPatientByRemoteId(String remoteId) async {
  var rep = await createPatientRepository();
  var found = await rep.findByRemoteId(remoteId);
  return found;
}
