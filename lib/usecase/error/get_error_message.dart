import 'dart:io';

import 'package:dio/dio.dart';
import 'package:mala_front/models/errors/failed_to_refresh_jwt.dart';
import 'package:vit_dart_extensions/vit_dart_extensions.dart';

String? getErrorMessage(Object obj) {
  if (obj is DioException) {
    var response = obj.response;
    if (response != null) {
      var data = response.data;
      if (data is Map<String, dynamic>) {
        var msg = _getMessageFromMap(data);
        if (msg != null) return msg;
        return data.prettyJSON;
      }
      if (data is String) {
        return data;
      }
    }
    var error = obj.error;
    if (error != null) {
      var msg = getErrorMessage(error);
      return 'Unable to connect to the server: $msg';
    }
  }
  if (obj is SocketException) {
    var server = obj.address;
    var msg = obj.osError;
    return 'Unable to connect to server: $server. Message: ${msg?.message}';
  }
  if (obj is Exception) {
    return obj.toString();
  }
  if (obj is TypeError) {
    return obj.toString();
  }
  if (obj is Error) {
    return obj.toString();
  }
  if (obj is FailedToRefreshJwt) {
    return 'Falha ao autalizar token de autenticação';
  }
  return null;
}

String? _getMessageFromMap(Map<String, dynamic> map) {
  var msg = map['message'];
  if (msg is String) {
    return msg;
  }
  var error = map['error'];
  if (error is Map<String, dynamic>) {
    return _getMessageFromMap(map);
  }
  return null;
}
