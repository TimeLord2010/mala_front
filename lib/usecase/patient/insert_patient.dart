import 'package:mala_front/factories/patient_repository.dart';
import 'package:mala_front/models/patient.dart';

Future<Patient> insertPatient(Patient patient) async {
  var rep = await createPatientRepository();
  return rep.insert(patient);
  // TODO: handle index conflicts
}
