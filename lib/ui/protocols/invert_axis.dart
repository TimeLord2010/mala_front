import 'package:flutter/widgets.dart';

Axis invertAxis(Axis axis) {
  return switch (axis) {
    Axis.horizontal => Axis.vertical,
    Axis.vertical => Axis.horizontal,
  };
}
