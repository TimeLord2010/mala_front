import 'package:camera_universal/camera_universal.dart';
import 'package:flutter/cupertino.dart';
import 'package:mala_api/mala_api.dart';
import 'package:mala_front/data/enums/camera_exception_reason.dart';
import 'package:mala_front/data/errors/failed_to_take_picture.dart';

import '../../../theme/colors.dart';

class PictureButton extends StatelessWidget {
  const PictureButton({
    super.key,
    this.color = black,
    required this.controller,
    required this.onPictureTaken,
  });

  final CameraController controller;
  final void Function(String path) onPictureTaken;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () async {
          try {
            var result = await controller.action_take_picture(
              onCameraNotInit: () {
                throw FailedToTakePicture(CameraExceptionReason.didNotInit);
              },
              onCameraNotSelect: () {
                throw FailedToTakePicture(CameraExceptionReason.didNotSelect);
              },
              onCameraNotActive: () {
                throw FailedToTakePicture(CameraExceptionReason.didNotActivate);
              },
            );
            if (result == null) {
              throw FailedToTakePicture(CameraExceptionReason.canceled);
            }
            var name = result.name;
            logger.info('Name: $name');
            var path = result.path;
            logger.info('Path: $path');
            onPictureTaken(path);
          } on Exception catch (e) {
            logger.error('Failed to take picture: ${e.toString()}');
          }
        },
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: color,
              width: 3,
            ),
          ),
          padding: const EdgeInsets.all(2),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}
