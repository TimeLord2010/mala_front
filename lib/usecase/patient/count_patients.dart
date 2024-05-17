import 'package:mala_front/factories/patient_repository.dart';
import 'package:mala_front/models/patient_query.dart';

Future<int> countPatients(PatientQuery query) async {
  //var stopWatch = VitStopWatch('countPatients');
  var rep = await createPatientRepository();
  var count = await rep.count(query);
  //stopWatch.stop();
  return count;
}
