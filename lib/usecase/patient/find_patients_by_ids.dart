import 'package:mala_front/factories/patient_repository.dart';

import '../../models/patient.dart';

Future<List<Patient>> findPatientsByIds(List<int> ids) async {
  var rep = await createPatientRepository();
  return rep.findByIds(ids);
}
