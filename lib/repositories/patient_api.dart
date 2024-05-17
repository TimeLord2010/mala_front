import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:mala_front/factories/http_client.dart';
import 'package:mala_front/factories/logger.dart';
import 'package:mala_front/models/api_responses/get_patient_changes_response.dart';
import 'package:mala_front/models/api_responses/post_patient_changes_response.dart';
import 'package:mala_front/models/patient.dart';
import 'package:mala_front/usecase/error/get_error_message.dart';
import 'package:vit_dart_extensions/vit_dart_extensions_io.dart';
import 'package:vit_logger/vit_logger.dart';

class PatientApiRepository {
  Future<GetPatientChangesResponse> getServerChanges({
    int? skip,
    int? limit,
    DateTime? date,
  }) async {
    var stopWatch = VitStopWatch('api:getServerChanges');
    if (date != null) {
      stopWatch.lap(tag: date.toIso8601String());
    }
    Map<String, dynamic> query = {
      ...(skip == null) ? {} : {'skip': skip},
      ...(limit == null) ? {} : {'limit': limit},
      ...(date == null) ? {} : {'date': date.toUtc().toIso8601String()},
    };
    var response = await dio.get(
      '/patient/sync',
      queryParameters: query,
    );
    Map<String, dynamic> body = response.data;
    stopWatch.stop();
    return GetPatientChangesResponse.fromMap(body);
  }

  Future<PostPatientChangesResponse> postChanges({
    List<Patient>? changed,
    List<String>? deleted,
  }) async {
    var stopWatch = VitStopWatch('api:postChanges');
    var response = await dio.post(
      '/patient/sync',
      data: {
        'changed': (changed ?? []).map((x) {
          if (x.remoteId == null) {
            logger.info('Uploading new patient: ${x.name}');
          } else {
            logger.info('Uploading changed to patient: ${x.name}');
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
    var stopWatch = VitStopWatch('api:updatePicture');
    String extension = file.fileExtension!;
    var uploadUrl = await _getUploadUrl(patientId, extension);
    try {
      var data = await file.readAsBytes();
      var size = data.lengthInBytes ~/ 1024;
      stopWatch.lap(tag: '$size kb');
      await dio.put(
        uploadUrl,
        data: data,
        options: Options(
          headers: {
            'Content-Type': 'application/octet-stream',
          },
        ),
      );
    } on DioException catch (e) {
      logger.error('Error uploading picture: ${getErrorMessage(e)}');
    }
    stopWatch.stop();
  }

  /// Fetches the picture data to the appropriate file.
  Future<void> savePicture(String patientId, String path) async {
    var stopWatch = VitStopWatch('api:savePicture:$patientId');
    try {
      var downloadUrl = await _getDownloadUrl(patientId, stopWatch: stopWatch);
      if (downloadUrl == null) {
        return;
      }
      await dio.download(downloadUrl, path);
    } finally {
      stopWatch.stop();
    }
  }

  /// Fetches the profile picture data.
  Future<Uint8List?> getPicture(String remoteId) async {
    var stopWatch = VitStopWatch('api:getPicture:$remoteId');
    try {
      var downloadUrl = await _getDownloadUrl(remoteId, stopWatch: stopWatch);
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
    } finally {
      stopWatch.stop();
    }
  }

  Future<String?> _getDownloadUrl(
    String remoteId, {
    VitStopWatch? stopWatch,
  }) async {
    bool createdStopWatch = false;
    if (stopWatch == null) {
      createdStopWatch = true;
      stopWatch = VitStopWatch('api:getDownloadUrl:$remoteId');
    }
    try {
      var url = '/patient/picture/download';
      var response = await dio.get(
        url,
        queryParameters: {
          'patientId': remoteId,
        },
      );
      if (!createdStopWatch) stopWatch.lap(tag: 'Fetched download url');
      String downloadUrl = response.data;
      return downloadUrl;
    } on DioException catch (e) {
      var response = e.response;
      if (response != null) {
        var code = response.statusCode;
        if (code == 404) {
          logger.warn('[$remoteId] No picture data found from the api');
          return null;
        }
      }
      rethrow;
    } finally {
      if (createdStopWatch) stopWatch.stop();
    }
  }

  Future<String> _getUploadUrl(String patientId, String extension) async {
    var stopWatch = VitStopWatch('api:getUploadUrl');
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
    var stopWatch = VitStopWatch('api:deletePicture');
    await dio.delete(
      '/patient/picture',
      queryParameters: {
        'patientId': patientId,
      },
    );
    stopWatch.stop();
  }
}
