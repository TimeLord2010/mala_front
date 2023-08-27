import 'package:mala_front/factories/patient_repository.dart';
import 'package:mala_front/models/patient.dart';

Future<List<Patient>> listPatients() async {
  var rep = createPatientRepository();
  return rep.list();
}
