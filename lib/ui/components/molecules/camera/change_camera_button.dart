import 'package:camera_universal/camera_universal.dart';
import 'package:flutter/material.dart';
import 'package:vit/vit.dart';

import '../../../protocols/camera/change_camera.dart';

class ChangeCameraButton extends StatelessWidget {
  const ChangeCameraButton({
    super.key,
    required this.controller,
    required this.updateUI,
    required this.selectedIndex,
    required this.isMounted,
    required this.setCameraIndex,
  });

  final CameraController controller;
  final void Function(void Function()) updateUI;
  final int selectedIndex;
  final bool Function() isMounted;
  final void Function(int) setCameraIndex;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: true == false
          ? () async {
              var newIndex = await changeCamera(
                controller: controller,
                selectedIndex: selectedIndex,
                setState: updateUI,
                isMounted: isMounted,
              );
              if (newIndex != null) {
                logInfo('Setting new camera index: $newIndex');
                setCameraIndex(newIndex);
              }
            }
          : null,
      icon: const Icon(Icons.cameraswitch),
    );
  }
}
