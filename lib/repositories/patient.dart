import 'package:isar/isar.dart';
import 'package:mala_front/models/address.dart';
import 'package:mala_front/models/patient.dart';

class PatientRepository {
  final Isar isar;

  PatientRepository({
    required this.isar,
  });

  Future<List<Patient>> list({
    String? name,
    int skip = 0,
    int limit = 100,
  }) async {
    var where = isar.patients.where();
    var docs = await where.nameStartsWith(name ?? '').sortByName().offset(skip).limit(limit).findAll();
    return docs;
  }

  Future<Patient> insert(Patient patient) async {
    await isar.writeTxn(() async {
      await isar.patients.put(patient);
      var address = patient.address.value;
      if (address != null) {
        await isar.address.put(address);
      }
      await patient.address.save();
    });
    return patient;
  }
}
