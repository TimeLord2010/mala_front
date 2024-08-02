import 'package:mala_front/data/enums/app_operation_mode.dart';
import 'package:mala_front/data/factories/create_database_client.dart';
import 'package:mala_front/data/interfaces/patient_interface.dart';
import 'package:mala_front/data/models/configuration.dart';
import 'package:mala_front/repositories/local_patient_repository.dart';

Future<PatientInterface> createPatientRepository() async {
  return switch (Configuration.mode) {
    AppOperationMode.offline => LocalPatientRepository(await createDatabaseClient()),
    _ => throw Exception('Not implemented'),
  };
}
