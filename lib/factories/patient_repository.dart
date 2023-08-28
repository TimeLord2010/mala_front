import 'package:mala_front/factories/database_client.dart';
import 'package:mala_front/repositories/patient.dart';

Future<PatientRepository> createPatientRepository() async {
  var db = await createDatabaseClient();
  return PatientRepository(
    isar: db,
  );
}
