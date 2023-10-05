import 'dart:io';

import 'package:dio/dio.dart';

bool isNoInternetError(Object? err) {
  if (err is SocketException) {
    return true;
  }
  if (err is DioException) {
    var inner = err.error;
    return isNoInternetError(inner);
  }
  return false;
}
