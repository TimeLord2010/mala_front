import 'package:camera_universal/camera_universal.dart';
import 'package:flutter/material.dart';
import 'package:mala_front/ui/components/molecules/camera/change_camera_button.dart';
import 'package:mala_front/ui/components/molecules/camera/picture_button.dart';
import 'package:mala_front/usecase/file/pick_image.dart';

class PictureTakerControlPanel extends StatelessWidget {
  const PictureTakerControlPanel({
    super.key,
    required this.direction,
    required this.cameraController,
    required this.selectedIndex,
    required this.updateUI,
    required this.isMounted,
    required this.setCameraIndex,
    required this.onPictureTaken,
  });

  final Axis direction;
  final CameraController cameraController;
  final int selectedIndex;
  final void Function(void Function()) updateUI;
  final bool Function() isMounted;
  final void Function(int index) setCameraIndex;
  final void Function(String? path) onPictureTaken;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Flex(
        direction: direction,
        children: [
          const Expanded(
            child: Align(
              alignment: Alignment.topCenter,
              child: BackButton(),
            ),
          ),
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: PictureButton(
                  controller: cameraController,
                  onPictureTaken: (path) {
                    onPictureTaken(path);
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: Flex(
              direction: direction,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ChangeCameraButton(
                  controller: cameraController,
                  isMounted: isMounted,
                  selectedIndex: selectedIndex,
                  updateUI: updateUI,
                  setCameraIndex: setCameraIndex,
                ),
                AspectRatio(
                  aspectRatio: 1,
                  child: IconButton(
                    onPressed: () async {
                      var path = await pickImage();
                      onPictureTaken(path);
                    },
                    icon: const Icon(Icons.folder_copy),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
