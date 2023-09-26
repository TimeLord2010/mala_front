import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:mala_front/factories/http_client.dart';
import 'package:mala_front/models/api_responses/get_patient_changes_response.dart';
import 'package:mala_front/models/api_responses/post_patient_changes_response.dart';
import 'package:mala_front/models/patient.dart';
import 'package:mala_front/usecase/error/get_error_message.dart';
import 'package:vit/vit.dart';

class PatientApiRepository {
  Future<GetPatientChangesResponse> getServerChanges({
    int? skip,
    int? limit,
    DateTime? date,
  }) async {
    var stopWatch = StopWatch('api:getServerChanges');
    var response = await dio.get(
      '/patient/sync',
      queryParameters: {
        ...(skip == null) ? {} : {'skip': skip},
        ...(limit == null) ? {} : {'limit': limit},
        ...(date == null) ? {} : {'date': date.toUtc().toIso8601String()},
      },
    );
    Map<String, dynamic> body = response.data;
    stopWatch.stop();
    return GetPatientChangesResponse.fromMap(body);
  }

  Future<PostPatientChangesResponse> postChanges({
    List<Patient>? changed,
    List<String>? deleted,
  }) async {
    var stopWatch = StopWatch('api:postChanges');
    var response = await dio.post(
      '/patient/sync',
      data: {
        'changed': (changed ?? []).map((x) {
          if (x.remoteId == null) {
            logInfo('Uploading new patient: ${x.name}');
          } else {
            logInfo('Uploading changed to patient: ${x.name}');
          }
          var toApiMap = x.toApiMap;
          return toApiMap;
        }).toList(),
        'delete': (deleted ?? []),
      },
    );
    stopWatch.stop();
    return PostPatientChangesResponse.fromMap(response.data);
  }

  Future<void> updatePicture({
    required String patientId,
    required File file,
  }) async {
    var stopWatch = StopWatch('api:updatePicture');
    String extension = file.fileExtension!;
    var uploadUrl = await _getUploadUrl(patientId, extension);
    try {
      await dio.put(
        uploadUrl,
        data: await file.readAsBytes(),
        options: Options(
          headers: {
            'Content-Type': 'application/octet-stream',
          },
        ),
      );
    } on DioException catch (e) {
      logError('Error uploading picture: ${getErrorMessage(e)}');
    }
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
    var response = await dio.get(
      downloadUrl,
      options: Options(
        responseType: ResponseType.bytes,
      ),
    );
    var data = response.data;
    if (data is String) {
      data = Uint8List.fromList(data.codeUnits);
    }
    if (data is Uint8List) {
      Uint8List bytes = data;
      return bytes;
    }
    throw Exception('Failed to load picture: Data was not a list of bytes: Type found=${data.runtimeType}');
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
