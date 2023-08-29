import 'package:isar/isar.dart';
import 'package:mala_front/models/address.dart';
import 'package:mala_front/models/patient.dart';
import 'package:mala_front/models/patient_query.dart';
import 'package:vit/vit.dart';

class PatientRepository {
  final Isar isar;

  PatientRepository({
    required this.isar,
  });

  Future<List<Patient>> list(
    PatientQuery query, {
    int? skip,
    int? limit,
  }) async {
    var docs = await query.buildWhere(isar).sortByName().offset(skip ?? 0).limit(limit ?? 60).findAll();
    return docs;
  }

  Future<int> count(PatientQuery query) async {
    var count = await query.buildWhere(isar).count();
    return count;
  }

  Future<Patient> insert(Patient patient) async {
    await isar.writeTxn(() async {
      logInfo('Saving patient: ${patient.name}');
      await isar.patients.put(patient);
    });
    logInfo('completed patient upsert: ${patient.name}');
    var address = patient.address.value;
    if (address != null) {
      await isar.writeTxn(() async {
        logInfo('Saving address');
        await isar.address.put(address);
        await patient.address.save();
      });
    }
    logInfo('completed address upsert: ${patient.name}');
    return patient;
  }

  Future<void> delete(int patientId) async {
    await isar.writeTxn(() async {
      await isar.patients.delete(patientId);
    });
  }
}
