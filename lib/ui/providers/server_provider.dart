import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:mala_api/mala_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ServerProvider {
  final _sp = GetIt.I.get<SharedPreferences>();
  final _logger = createSdkLogger('ServerProvider');

  String? _address;
  String get address {
    // Caching the old value from this getter
    if (_address != null) {
      _logger.i('Found cached ip: $_address');
      return _address!;
    }
    String generateValue() {
      // Fetch saved value from storage
      var saved = _sp.getString('server');
      if (saved != null) {
        _logger.i('Found saved ip: $saved');
        return saved;
      }

      // Assume default values
      var lambdaAddress = ApiAddreess.prod.address;
      var address = lambdaAddress;
      _logger.i('Assumed address: $address');
      return address;
    }

    final value = generateValue();
    _address = value;
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
    _address = address;
  }
}

enum ApiAddreess {
  prod,
  dev;

  String get awsId {
    return switch (this) {
      prod => 'aj18h1vzgh',
      dev => 'qt3ytu5rh4',
    };
  }

  String get address {
    return 'https://$awsId.execute-api.us-east-1.amazonaws.com/Prod/';
  }
}
