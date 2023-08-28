import 'package:isar/isar.dart';
import 'package:mala_front/models/address.dart';
import 'package:mala_front/models/patient.dart';
import 'package:mala_front/usecase/file/get_database_directory.dart';

Isar? _isar;

Future<Isar> createDatabaseClient() async {
  if (_isar == null) {
    final dir = await getDatabaseDirectory();
    _isar = await Isar.open(
      [PatientSchema, AddressSchema],
      directory: dir.path,
    );
  }
  return _isar!;
}
