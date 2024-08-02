import 'package:mala_front/data/enums/camera_exception_reason.dart';

class CameraException implements Exception {
  final CameraExceptionReason? reason;
  CameraException(this.reason);
}
