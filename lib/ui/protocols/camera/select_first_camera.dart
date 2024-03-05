import 'package:camera/camera.dart' as camera_package;
import 'package:camera_universal/camera_universal.dart';

Future<void> selectFistCamera({
  required CameraController controller,
  required void Function(void Function()) updateUI,
}) async {
  try {
    await controller.initializeCamera(
      setState: updateUI,
    );
  } on camera_package.CameraException {
    rethrow;
    // var description = e.description;
    // if (description == null) {
    //   rethrow;
    // }
    // var needsToDispose = description.contains('Camera with given id already exists.');
    // if (!needsToDispose) {
    //   rethrow;
    // }
    // if (!Platform.isWindows) {
    //   rethrow;
    // }
    // var cameras = controller.camera_mobile_datas;
    // var camera = cameras.first;
    // controller.camera_windows.dispose(cameraId);
  }
}
