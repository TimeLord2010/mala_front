import 'package:mala_front/data/factories/create_patient_repository.dart';

import '../../data/entities/patient.dart';

Future<List<Patient>> findPatientsByIds(List<int> ids) async {
  var rep = await createPatientRepository();
  return rep.findByIds(ids);
}
