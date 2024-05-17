import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:mala_front/factories/logger.dart';
import 'package:mala_front/models/address.dart';
import 'package:mala_front/models/patient.dart';
import 'package:mala_front/usecase/file/get_database_directory.dart';

Isar? _isar;

Future<Isar> createDatabaseClient() async {
  if (_isar == null) {
    final dir = await getDatabaseDirectory();
    logger.info('Database directory: ${dir.path}');
    _isar = await Isar.open(
      [PatientSchema, AddressSchema],
      directory: dir.path,
      inspector: kDebugMode,
      compactOnLaunch: const CompactCondition(
        minRatio: 1.5,
      ),
    );
  }
  return _isar!;
}

void destroyDatabaseClient() {
  _isar = null;
}
