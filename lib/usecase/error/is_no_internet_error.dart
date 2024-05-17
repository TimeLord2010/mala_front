import 'dart:io';

import 'package:dio/dio.dart';
import 'package:mala_front/models/errors/failed_to_refresh_jwt.dart';

bool isNoInternetError(Object? err) {
  if (err is FailedToRefreshJwt) {
    return isNoInternetError(err.innerException);
  }
  if (err is SocketException) {
    return true;
  }
  if (err is DioException) {
    var inner = err.error;
    return isNoInternetError(inner);
  }
  return false;
}
