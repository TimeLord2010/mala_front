import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:mala_front/models/address.dart';
import 'package:mala_front/models/patient.dart';
import 'package:mala_front/usecase/file/get_database_directory.dart';
import 'package:vit/vit.dart';

Isar? _isar;

Future<Isar> createDatabaseClient() async {
  if (_isar == null) {
    final dir = await getDatabaseDirectory();
    logInfo('Database directory: ${dir.path}');
    _isar = await Isar.open(
      [PatientSchema, AddressSchema],
      directory: dir.path,
      maxSizeMiB: 5,
      inspector: kDebugMode,
      compactOnLaunch: const CompactCondition(
        minRatio: 1.5,
      ),
    );
  }
  return _isar!;
}
