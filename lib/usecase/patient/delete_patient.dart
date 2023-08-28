import 'package:mala_front/factories/patient_repository.dart';

Future<void> deletePatient(int patientId) async {
  var rep = await createPatientRepository();
  await rep.delete(patientId);
}
