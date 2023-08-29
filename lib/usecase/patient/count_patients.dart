import 'package:mala_front/factories/patient_repository.dart';
import 'package:mala_front/models/patient_query.dart';

Future<int> countPatients(PatientQuery query) async {
  var rep = await createPatientRepository();
  return rep.count(query);
}
