import 'package:dio/dio.dart';
import 'package:vit/vit.dart';

String? getErrorMessage(Object obj) {
  if (obj is Exception) {
    return _getMessageFromException(obj);
  }
  return null;
}

String? _getMessageFromException(Exception exception) {
  if (exception is DioException) {
    var response = exception.response;
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
    var error = exception.error;
    if (error != null) {
      var msg = getErrorMessage(error);
      return 'Unable to connect to the server: $msg';
    }
  }
  return exception.toString();
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
