import 'package:mala_front/factories/patient_repository.dart';
import 'package:mala_front/models/patient.dart';
import 'package:mala_front/models/patient_query.dart';

Future<List<Patient>> listPatients({
  required PatientQuery patientQuery,
  int? skip,
  int? limit,
}) async {
  //var stopWatch = VitStopWatch('listPatients');
  var rep = await createPatientRepository();
  var patients = <Patient>[];
  var l = await rep.list(
    patientQuery,
    skip: skip,
    limit: limit,
  );
  patients.addAll(l);
  // stopWatch.lap(tag: '${patients.length} items');
  // stopWatch.stop();
  return patients;
}
