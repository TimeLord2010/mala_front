import 'package:mala_front/factories/patient_repository.dart';

Future<int> countAllPatients() async {
  var rep = await createPatientRepository();
  var count = await rep.count();
  return count;
}
