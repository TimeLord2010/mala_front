import 'dart:io';

import 'package:camera/camera.dart' as camera_package;
import 'package:camera_universal/camera_universal.dart';
import 'package:flutter/material.dart';
import 'package:mala_front/models/errors/camera_exception.dart' as model;
import 'package:mala_front/ui/components/organisms/picture_taker_control_panel.dart';
import 'package:mala_front/ui/protocols/camera/get_camera_count.dart';
import 'package:mala_front/ui/protocols/invert_axis.dart';
import 'package:mala_front/ui/theme/text_styles/error_text_style.dart';
import 'package:mala_front/usecase/error/get_error_message.dart';
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
  int camerasCount = 0;
  int selectedIndex = 0;

  @override
  void initState() {
    logInfo('Init state profile picture');
    super.initState();
    task();
  }

  Future<void> task() async {
    try {
      // Get available cameras
      await cameraController.initializeCameras();

      var camerasCount = getCameraCount(cameraController);

      if (camerasCount == 0) {
        logWarn('No cameras found');
        return;
      }

      // Select fist camera
      await cameraController.initializeCamera(
        setState: setState,
      );

      // Initialize selected camera
      await cameraController.activateCamera(
        setState: setState,
        mounted: () => mounted,
      );

      logInfo('Camera count: $camerasCount');
      setState(() {
        this.camerasCount = camerasCount;
      });
    } on camera_package.CameraException catch (e) {
      logError('Internal camera exception: (${e.code}) ${e.description}');
    } on model.CameraException catch (e) {
      logError('Camera exception: $e');
    } on Exception catch (e) {
      logError(getErrorMessage(e) ?? 'Camera initialization error');
    }
  }

  @override
  void dispose() {
    logInfo('[PictureTaker] dispose');
    if (Platform.isWindows) {
      var cameraId = cameraController.camera_id;
      if (cameraId != 0) {
        logInfo('Disposing of camereId $cameraId');
        cameraController.camera_windows.dispose(cameraId);
      }
    }
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
              child: PictureTakerControlPanel(
                direction: invertAxis(direction),
                cameraController: cameraController,
                isMounted: () => mounted,
                updateUI: setState,
                selectedIndex: selectedIndex,
                setCameraIndex: (index) {
                  setState(() {
                    selectedIndex = index;
                  });
                },
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
}
