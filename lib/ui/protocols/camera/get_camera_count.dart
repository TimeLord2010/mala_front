import 'package:camera_universal/camera_universal.dart';

int getCameraCount(CameraController controller) {
  var didInit = controller.is_camera_init;
  if (!didInit) {
    return 0;
  }
  var cameras = controller.camera_mobile_datas;
  var count = cameras.length;
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
