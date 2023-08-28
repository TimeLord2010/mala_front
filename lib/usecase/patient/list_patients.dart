import 'package:mala_front/factories/patient_repository.dart';
import 'package:mala_front/models/patient.dart';
import 'package:vit/vit.dart';

Future<List<Patient>> listPatients() async {
  var stopWatch = StopWatch('listPatients');
  var rep = await createPatientRepository();
  stopWatch.lap(tag: 'connect');
  var patients = rep.list();
  stopWatch.stop();
  return patients;
}
