import 'dart:io';

import 'package:flutter/foundation.dart';

class Features {
  static bool imageSuport = !(Platform.isWindows && kDebugMode);
}