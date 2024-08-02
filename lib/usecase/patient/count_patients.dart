import 'package:mala_front/data/entities/patient_query.dart';
import 'package:mala_front/data/factories/create_patient_repository.dart';

Future<int> countPatients(PatientQuery query) async {
  //var stopWatch = VitStopWatch('countPatients');
  var rep = await createPatientRepository();
  var count = await rep.count(query);
  //stopWatch.stop();
  return count;
}
