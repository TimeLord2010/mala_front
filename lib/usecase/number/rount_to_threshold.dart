import 'package:flutter/foundation.dart';

double roundToThreshold(double number, [double threshold = 0.000001]) {
  double diff = (number + 1).ceilToDouble() - number;
  diff -= 1;
  if (diff < threshold) {
    var newValue = number.ceilToDouble();
    debugPrint('Original number: $number. New number: $newValue');
    return newValue;
  }
  return number;
}
