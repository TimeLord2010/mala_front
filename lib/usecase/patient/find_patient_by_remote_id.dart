import 'package:mala_front/factories/patient_repository.dart';
import 'package:vit/vit.dart';

Future<int?> findPatientByRemoteId(String remoteId) async {
  var stopWatch = StopWatch('findPatientByRemoteId');
  var rep = await createPatientRepository();
  var id = await rep.findIdByRemoteId(remoteId);
  stopWatch.stop();
  return id;
}
