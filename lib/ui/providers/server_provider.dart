import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:mala_api/mala_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ServerProvider {
  final _sp = GetIt.I.get<SharedPreferences>();

  String? _ip;
  String get ip {
    // Chaching the old value from this getter
    if (_ip != null) {
      logger.info('Found cached ip: $_ip');
      return _ip!;
    }
    String generateValue() {
      // Fetch saved value from storage
      var saved = _sp.getString('server');
      if (saved != null) {
        logger.info('Found saved ip: $saved');
        return saved;
      }

      // Assume default values
      var s =
          kDebugMode ? 'http://localhost:49152' : 'http://3.220.73.81:49152';
      logger.info('Assumed ip: $s');
      return s;
    }

    final value = generateValue();
    _ip = value;
    return value;
  }

  void refreshHttpClient(String value) {
    logger.info('Refreshed http client: $value');
    dio = Dio(BaseOptions(
      baseUrl: value,
    ));
  }

  void updateServer(String address) {
    refreshHttpClient(address);
    unawaited(_sp.setString('server', address));
  }
}
