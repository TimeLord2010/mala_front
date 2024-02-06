import 'package:camera_universal/camera_universal.dart';
import 'package:flutter/material.dart';
import 'package:mala_front/ui/protocols/camera/change_camera.dart';
import 'package:vit/vit.dart';

class PictureTakerControlPanel extends StatelessWidget {
  const PictureTakerControlPanel({
    super.key,
    required this.direction,
    required this.cameraController,
    required this.selectedIndex,
    required this.updateUI,
    required this.isMounted,
    required this.setCameraIndex,
  });

  final Axis direction;
  final CameraController cameraController;
  final int selectedIndex;
  final void Function(void Function()) updateUI;
  final bool Function() isMounted;
  final void Function(int index) setCameraIndex;

  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: direction,
      children: [
        const Expanded(
          child: Center(
            child: BackButton(),
          ),
        ),
        const Expanded(
          child: Center(
            child: AspectRatio(
              aspectRatio: 1,
              child: Placeholder(),
            ),
          ),
        ),
        Expanded(
          child: Flex(
            direction: direction,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                onPressed: () async {
                  var newIndex = await changeCamera(
                    controller: cameraController,
                    selectedIndex: selectedIndex,
                    setState: updateUI,
                    isMounted: isMounted,
                  );
                  if (newIndex != null) {
                    logInfo('Setting new camera index: $newIndex');
                    setCameraIndex(newIndex);
                  }
                },
                icon: const Icon(Icons.cameraswitch),
              ),
              const AspectRatio(
                aspectRatio: 1,
                child: Placeholder(
                  color: Colors.purple,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
