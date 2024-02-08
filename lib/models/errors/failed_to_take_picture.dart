import 'package:mala_front/models/errors/camera_exception.dart';

class FailedToTakePicture extends CameraException {
  FailedToTakePicture(super.reason);
}
