import 'package:camera_universal/camera_universal.dart';

int getCameraCount(CameraController controller) {
  var count = controller.camera_mobile_datas.length;
  // var count = controller.action_get_camera_count(
  //   onCameraNotInit: () {
  //     throw FailedToCountCameras(CameraExceptionReason.didNotInit);
  //   },
  //   onCameraNotSelect: () {
  //     throw FailedToCountCameras(CameraExceptionReason.didNotSelect);
  //   },
  //   onCameraNotActive: () {
  //     throw FailedToCountCameras(CameraExceptionReason.didNotActivate);
  //   },
  // );
  return count;
}
