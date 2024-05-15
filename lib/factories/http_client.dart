import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

var dio = Dio(BaseOptions(
  baseUrl: kDebugMode ? 'http://localhost:49152' : 'http://3.220.73.81:49152',
  // baseUrl: 'http://3.220.73.81:49152',
));
