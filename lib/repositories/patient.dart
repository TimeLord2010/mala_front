import 'package:flutter/widgets.dart';
import 'package:isar/isar.dart';
import 'package:mala_front/models/address.dart';
import 'package:mala_front/models/patient.dart';
import 'package:mala_front/models/patient_query.dart';
import 'package:vit_logger/vit_logger.dart';

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
    var docs = await query.buildQuery(isar).offset(skip ?? 0).limit(limit ?? 60).findAll();
    return docs;
  }

  Future<Patient?> findById(int id) async {
    var patient = await isar.patients.get(id);
    return patient;
  }

  Future<List<Patient>> findByIds(List<int> ids) {
    var where = isar.patients.where();
    var first = ids.removeAt(0);
    var afterWhere = where.idEqualTo(first);
    while (ids.isNotEmpty) {
      afterWhere = afterWhere.or().idEqualTo(ids.removeAt(0));
    }
    return afterWhere.findAll();
  }

  Future<Iterable<Patient>> listUsingCreatedAts({
    required Iterable<DateTime> createdAts,
  }) async {
    var where = isar.patients.where();
    var query = where.createdAtIsNotNull();
    for (var dt in createdAts) {
      query = query.or().createdAtEqualTo(dt);
    }
    return query.findAll();
  }

  Future<List<Patient>> findLocalPatients({
    required int skip,
    required int limit,
  }) {
    var stopWatch = VitStopWatch('findLocalPatients');
    var where = isar.patients.where();
    var patients = where.remoteIdIsNull().offset(skip).limit(limit).findAll();
    stopWatch.stop();
    return patients;
  }

  Future<int?> findIdByRemoteId(String remoteId) async {
    var where = isar.patients.where();
    var id = await where.remoteIdEqualTo(remoteId).idProperty().findFirst();
    return id;
  }

  Future<int> count([PatientQuery? query]) async {
    if (query == null) {
      return isar.patients.count();
    }
    var count = await query.buildQuery(isar).count();
    return count;
  }

  Future<Patient> insert(Patient patient) async {
    // var oldId = patient.id;
    await isar.writeTxn(() async {
      var hadId = patient.id > 0;
      var id = await isar.patients.put(patient);
      if (!hadId) debugPrint('New id: $id');
    });
    // var inserted = oldId != patient.id;
    // if (inserted) {
    //   logger.info('INSERTED PATIENT!!!');
    // } else {
    //   logger.info('UPDATED PATIENT!!!');
    // }
    var address = patient.address.value;
    if (address != null) {
      await isar.writeTxn(() async {
        await isar.address.put(address);
        await patient.address.save();
      });
    }
    return patient;
  }

  Future<void> delete(int patientId) async {
    await isar.writeTxn(() async {
      await isar.patients.delete(patientId);
    });
  }
}
