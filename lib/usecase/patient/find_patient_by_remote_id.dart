import 'package:mala_front/data/factories/create_patient_repository.dart';
import 'package:vit_logger/vit_logger.dart';

Future<int?> findPatientByRemoteId(String remoteId) async {
  var stopWatch = VitStopWatch('findPatientByRemoteId');
  var rep = await createPatientRepository();
  var id = await rep.findIdByRemoteId(remoteId);
  stopWatch.stop();
  return id;
}
