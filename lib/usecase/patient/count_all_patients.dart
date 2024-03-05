import 'package:mala_front/factories/patient_repository.dart';

/// Calculates the number os patients in the local storage.
Future<int> countAllPatients() async {
  var rep = await createPatientRepository();
  var count = await rep.count();
  return count;
}
