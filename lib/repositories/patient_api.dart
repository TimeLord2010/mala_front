import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:mala_front/factories/http_client.dart';
import 'package:mala_front/models/api_responses/patient_changes_response.dart';
import 'package:mala_front/models/patient.dart';
import 'package:vit/vit.dart';

class PatientApiRepository {
  Future<List<Patient>> getNewPatients({
    int? skip,
    int? limit,
    DateTime? date,
  }) async {
    var stopWatch = StopWatch('api:getNewPatients');
    var response = await dio.get(
      '/patient/sync',
      queryParameters: {
        ...(skip == null) ? {} : {'skip': skip},
        ...(limit == null) ? {} : {'limit': limit},
        ...(date == null) ? {} : {'date': date.toUtc().toIso8601String()},
      },
    );
    List rawPatients = response.data;
    Iterable<Patient> patients = rawPatients.map((x) => Patient.fromMap(x));
    stopWatch.stop();
    return patients.toList();
  }

  Future<PatientChangesResponse> postChanges({
    List<Patient>? changed,
    List<String>? deleted,
  }) async {
    var stopWatch = StopWatch('api:postChanges');
    var response = await dio.post(
      '/patient/sync',
      data: {
        'changed': (changed ?? []).map((x) {
          var toApiMap = x.toApiMap;
          return toApiMap;
        }).toList(),
        'delete': (deleted ?? []),
      },
    );
    stopWatch.stop();
    return PatientChangesResponse.fromMap(response.data);
  }

  Future<void> updatePicture({
    required String patientId,
    required File file,
  }) async {
    var stopWatch = StopWatch('api:updatePicture');
    String extension = file.fileExtension!;
    var uploadUrl = await _getUploadUrl(patientId, extension);
    await dio.put(
      uploadUrl,
      data: file.openRead(),
    );
    stopWatch.stop();
  }

  Future<void> savePicture(String patientId, String path) async {
    var downloadUrl = await getDownloadUrl(patientId);
    if (downloadUrl == null) {
      return;
    }
    await dio.download(downloadUrl, path);
  }

  Future<Uint8List?> getPicture(String patientId) async {
    var downloadUrl = await getDownloadUrl(patientId);
    if (downloadUrl == null) {
      return null;
    }
    var response = await dio.get(downloadUrl);
    Uint8List data = response.data;
    return data;
  }

  Future<String?> getDownloadUrl(String patientId) async {
    var stopWatch = StopWatch('api:getDownloadUrl:$patientId');
    try {
      var url = '/patient/picture/download';
      var response = await dio.get(
        url,
        queryParameters: {
          'patientId': patientId,
        },
      );
      String downloadUrl = response.data;
      return downloadUrl;
    } on DioException catch (e) {
      var response = e.response;
      if (response != null) {
        var code = response.statusCode;
        if (code == 404) {
          return null;
        }
      }
      rethrow;
    } finally {
      stopWatch.stop();
    }
  }

  Future<String> _getUploadUrl(String patientId, String extension) async {
    var stopWatch = StopWatch('api:getUploadUrl');
    var url = '/patient/picture/upload';
    var response = await dio.get(
      url,
      queryParameters: {
        'patientId': patientId,
        'extension': extension,
      },
    );
    String uploadUrl = response.data;
    stopWatch.stop();
    return uploadUrl;
  }

  Future<void> deletePicture({required String patientId}) async {
    var stopWatch = StopWatch('api:deletePicture');
    await dio.delete(
      '/patient/picture',
      queryParameters: {
        'patientId': patientId,
      },
    );
    stopWatch.stop();
  }
}
