import 'dart:io';

import 'package:camera/camera.dart' as camera_package;
import 'package:camera_universal/camera_universal.dart';
import 'package:mala_front/data/enums/camera_exception_reason.dart';
import 'package:mala_front/data/errors/failed_to_change_camera.dart';
import 'package:mala_front/data/factories/logger.dart';

Future<int?> changeCamera({
  required CameraController controller,
  required int selectedIndex,
  required void Function(void Function()) setState,
  required bool Function() isMounted,
}) async {
  var cameras = controller.camera_mobile_datas;
  var len = cameras.length;
  if (len < 2) {
    return null;
  }
  int getDesiredIndex() {
    if (selectedIndex >= len - 1) {
      return 0;
    }
    return selectedIndex + 1;
  }

  var desiredIndex = getDesiredIndex();
  logger.info('Desired index: $desiredIndex');
  var camera = cameras[desiredIndex];
  logger.info('New camera: ${camera.name}');

  int? cameraId;
  if (Platform.isWindows) {
    // Disposing old camera.
    var oldCameraId = controller.camera_id;
    logger.info('Disposing of old camera: $oldCameraId');
    await controller.camera_windows.dispose(oldCameraId);

    var con = controller.camera_windows;
    cameraId = await con.createCamera(
      camera,
      camera_package.ResolutionPreset.max,
    );
    logger.info('New camera id: $cameraId');
    await controller.initializeCameraById(
      camera_id: cameraId,
      setState: setState,
      mounted: isMounted,
    );
    //await con.initializeCamera(cameraId);
  }

  if (cameraId == null) {
    throw FailedToChangeCamera(CameraExceptionReason.notImplemented);
  }

  // await controller.action_change_camera(
  //   cameraId: cameraId,
  //   setState: setState,
  //   mounted: isMounted,
  //   onCameraNotInit: () {
  //     throw FailedToChangeCamera(CameraExceptionReason.didNotInit);
  //   },
  //   onCameraNotSelect: () {
  //     throw FailedToChangeCamera(CameraExceptionReason.didNotSelect);
  //   },
  //   onCameraNotActive: () {
  //     throw FailedToChangeCamera(CameraExceptionReason.didNotActivate);
  //   },
  // );
  return desiredIndex;
}
