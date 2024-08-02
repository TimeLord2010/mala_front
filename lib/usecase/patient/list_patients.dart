import 'package:mala_front/data/entities/patient.dart';
import 'package:mala_front/data/entities/patient_query.dart';
import 'package:mala_front/data/factories/create_patient_repository.dart';

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
