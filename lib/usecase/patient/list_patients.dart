import 'package:mala_front/factories/patient_repository.dart';
import 'package:mala_front/models/patient.dart';
import 'package:mala_front/models/patient_query.dart';
import 'package:vit/vit.dart';

Future<List<Patient>> listPatients({
  String? name,
  int? skip,
  int? limit,
}) async {
  var stopWatch = StopWatch('listPatients');
  var rep = await createPatientRepository();
  stopWatch.lap(tag: 'connect');
  var patients = await rep.list(
    PatientQuery(
      name: name,
    ),
    skip: skip,
    limit: limit,
  );
  stopWatch.lap(tag: '${patients.length} items');
  stopWatch.stop();
  return patients;
}
