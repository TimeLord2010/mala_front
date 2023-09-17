import 'package:mala_front/factories/http_client.dart';
import 'package:mala_front/models/patient.dart';

class PatientApiRepository {
  Future<List<Patient>> getNewPatients({
    int? skip,
    int? limit,
    bool? all,
  }) async {
    var response = await dio.get(
      '/patient/sync',
      queryParameters: {
        ...(skip == null) ? {} : {'skip': skip},
        ...(limit == null) ? {} : {'limit': limit},
        ...(all == null) ? {} : {'all': all},
      },
    );
    List rawPatients = response.data;
    Iterable<Patient> patients = rawPatients.map((x) => Patient.fromMap(x));
    return patients.toList();
  }

  Future<void> postChanges({
    List<Patient>? changed,
    List<String>? deleted,
  }) async {
    await dio.post(
      '/patient/sync',
      data: {
        'changed': (changed ?? []).map((x) => x.toApiMap).toList(),
        'delete': (deleted ?? []),
      },
    );
  }
}
