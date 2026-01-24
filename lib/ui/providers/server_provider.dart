import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:mala_api/mala_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ServerProvider {
  final _sp = GetIt.I.get<SharedPreferences>();
  final _logger = createSdkLogger('ServerProvider');

  String? _ip;
  String get ip {
    // Chaching the old value from this getter
    if (_ip != null) {
      _logger.i('Found cached ip: $_ip');
      return _ip!;
    }
    String generateValue() {
      // Fetch saved value from storage
      var saved = _sp.getString('server');
      if (saved != null) {
        _logger.i('Found saved ip: $saved');
        return saved;
      }

      // Assume default values
      var lambdaAddress =
          'https://aj18h1vzgh.execute-api.us-east-1.amazonaws.com/Prod/';
      var address = lambdaAddress;
      // var address = kDebugMode ? 'http://localhost:49152' : lambdaAddress;
      _logger.i('Assumed ip: $address');
      return address;
    }

    final value = generateValue();
    _ip = value;
    return value;
  }

  void refreshHttpClient(String value) {
    value = value.trim();
    _logger.i('Refreshed http client: $value');
    Configuration.updateUrl(value);
  }

  void updateServer(String address) {
    refreshHttpClient(address);
    unawaited(_sp.setString('server', address));
    _ip = address;
  }
}
