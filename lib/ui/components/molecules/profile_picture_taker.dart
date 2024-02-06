import 'package:camera_universal/camera_universal.dart';
import 'package:flutter/material.dart';
import 'package:mala_front/ui/protocols/invert_axis.dart';
import 'package:mala_front/ui/theme/text_styles/error_text_style.dart';
import 'package:vit/vit.dart';

import '../../theme/colors.dart';
import '../atoms/index.dart';

class ProfilePictureTaker extends StatefulWidget {
  const ProfilePictureTaker({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ProfilePictureTakerState();
  }
}

class _ProfilePictureTakerState extends State<ProfilePictureTaker> {
  final cameraController = CameraController();
  @override
  void initState() {
    logInfo('Init state profile picture');
    super.initState();
    task();
  }

  Future<void> task() async {
    await cameraController.initializeCameras();
    await cameraController.initializeCamera(
      setState: setState,
    );
    await cameraController.activateCamera(
      setState: setState,
      mounted: () {
        return mounted;
      },
    );
    var cameras = cameraController.action_get_camera_count(
      onCameraNotInit: () {
        logError('[Camera count] Camera not initalized');
      },
      onCameraNotSelect: () {
        logError('[Camera count] Camera not selected');
      },
      onCameraNotActive: () {
        logError('[Camera count] Camera not activated');
      },
    );
    logInfo('Camera count: $cameras');
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      body: LayoutBuilder(builder: (context, constraints) {
        var width = constraints.maxWidth;
        var direction = width > 600 ? Axis.horizontal : Axis.vertical;
        double controlPanelSize = 60;
        return Flex(
          direction: direction,
          children: [
            _cameraFrame(),
            SizedBox(
              width: direction == Axis.horizontal ? controlPanelSize : null,
              height: direction == Axis.vertical ? controlPanelSize : null,
              child: _controlPanel(
                direction: invertAxis(direction),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _cameraFrame() {
    return Expanded(
      child: Camera(
        cameraController: cameraController,
        onCameraNotInit: (context) {
          return const MalaText('Camera não inicializada');
        },
        onCameraNotSelect: (context) {
          return const MalaText('Camera não selecionada');
        },
        onCameraNotActive: (context) {
          return const MalaText('Camera não ativada');
        },
        onPlatformNotSupported: (context) {
          return const MalaText(
            'Plataforma não suportada',
            style: errorTextStyle,
          );
        },
      ),
    );
  }

  Widget _controlPanel({
    required Axis direction,
  }) {
    return Flex(
      direction: direction,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        BackButton(),
        AspectRatio(
          aspectRatio: 1,
          child: Placeholder(),
        ),
        AspectRatio(
          aspectRatio: 1,
          child: Placeholder(
            color: Colors.purple,
          ),
        ),
      ],
    );
  }
}
