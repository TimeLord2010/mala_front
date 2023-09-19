import 'package:mala_front/factories/patient_repository.dart';

import '../../models/patient.dart';

Future<Patient?> getPatientById(int id) async {
  var rep = await createPatientRepository();
  return rep.findById(id);
}
