import 'dart:io';
import 'dart:typed_data';

import 'package:mala_front/factories/http_client.dart';
import 'package:mala_front/models/patient.dart';
import 'package:vit/vit.dart';

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

  Future<void> updatePicture({
    required String patientId,
    required File file,
  }) async {
    String extension = file.fileExtension!;
    var uploadUrl = await _getUploadUrl(patientId, extension);
    await dio.put(
      uploadUrl,
      data: file.openRead(),
    );
  }

  Future<void> savePicture(String patientId, String path) async {
    var downloadUrl = await getDownloadUrl(patientId);
    await dio.download(downloadUrl, path);
  }

  Future<Uint8List> getPicture(String patientId) async {
    var downloadUrl = await getDownloadUrl(patientId);
    var response = await dio.get(downloadUrl);
    Uint8List data = response.data;
    return data;
  }

  Future<String> getDownloadUrl(String patientId) async {
    var url = '/patient/picture/download';
    var response = await dio.get(
      url,
      queryParameters: {
        'patientId': patientId,
      },
    );
    String downloadUrl = response.data;
    return downloadUrl;
  }

  Future<String> _getUploadUrl(String patientId, String extension) async {
    var url = '/patient/picture/upload';
    var response = await dio.get(
      url,
      queryParameters: {
        'patientId': patientId,
        'extension': extension,
      },
    );
    String uploadUrl = response.data;
    return uploadUrl;
  }
}
