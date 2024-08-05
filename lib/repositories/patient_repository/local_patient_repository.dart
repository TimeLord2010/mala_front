import 'package:flutter/widgets.dart';
import 'package:isar/isar.dart';
import 'package:mala_front/data/entities/address.dart';
import 'package:mala_front/data/entities/patient.dart';
import 'package:mala_front/data/entities/patient_query.dart';
import 'package:mala_front/data/interfaces/patient_interface.dart';
import 'package:vit_logger/vit_logger.dart';

class LocalPatientRepository extends PatientInterface<int> {
  final Isar isar;

  LocalPatientRepository(this.isar);

  @override
  Future<int> count([PatientQuery? query]) async {
    if (query == null) {
      return isar.patients.count();
    }
    var count = await query.buildQuery(isar).count();
    return count;
  }

  @override
  Future<void> delete(Patient patient) async {
    var id = getId(patient);
    await isar.writeTxn(() async {
      await isar.patients.delete(id);
    });
  }

  @override
  Future<List<Patient>> list(
    PatientQuery query, {
    int? skip,
    int? limit,
  }) async {
    var docs = await query.buildQuery(isar).offset(skip ?? 0).limit(limit ?? 60).findAll();
    return docs;
  }

  @override
  Future<Patient> upsert(Patient patient) async {
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

  /// Fetches the patients who do not have the "remoteId" field set.
  Future<List<Patient>> findLocalPatients({
    required int skip,
    required int limit,
  }) {
    var stopWatch = VitStopWatch('findLocalPatients');
    var query = isar.patients.where();
    var patients = query.remoteIdIsNull().offset(skip).limit(limit).findAll();
    stopWatch.stop();
    return patients;
  }

  @override
  Future<Patient?> getById(int id) async {
    var intId = getId(id);
    var patient = await isar.patients.get(intId);
    return patient;
  }

  @override
  Future<Iterable<Patient>> listByCreation(Iterable<DateTime> createdAts) {
    var where = isar.patients.where();
    var query = where.createdAtIsNotNull();
    for (var dt in createdAts) {
      query = query.or().createdAtEqualTo(dt);
    }
    return query.findAll();
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

  Future<int?> findIdByRemoteId(String remoteId) async {
    var where = isar.patients.where();
    var id = await where.remoteIdEqualTo(remoteId).idProperty().findFirst();
    return id;
  }

  int getId(data) {
    if (data is Patient) {
      return data.id;
    }
    if (data is int) {
      return data;
    }
    if (data is String) {
      return int.parse(data);
    }
    throw Exception('Falha ao obter id de paciente de: $data');
  }

  @override
  Future<void> deleteById(int id) {
    // TODO: implement deleteById
    throw UnimplementedError();
  }
}
