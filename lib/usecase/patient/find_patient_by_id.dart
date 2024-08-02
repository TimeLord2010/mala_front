import 'package:mala_front/data/factories/create_patient_repository.dart';

import '../../data/entities/patient.dart';

Future<Patient?> findPatientById(int id) async {
  var rep = await createPatientRepository();
  return rep.findById(id);
}
