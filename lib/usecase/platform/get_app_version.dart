import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

Future<String> getAppVersion([bool includeBuild = false]) async {
  var packageInfo = await PackageInfo.fromPlatform();
  String version = packageInfo.version;
  if (!includeBuild) {
    return version;
  }
  var buildNumber = packageInfo.buildNumber;
  debugPrint('build: $buildNumber');
  return '$version+$buildNumber';
}
