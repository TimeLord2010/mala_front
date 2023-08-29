import 'package:mala_front/factories/patient_repository.dart';
import 'package:vit/vit.dart';

Future<void> deletePatient(int patientId) async {
  var stopWatch = StopWatch('deletePatient');
  var rep = await createPatientRepository();
  await rep.delete(patientId);
  stopWatch.stop();
}
