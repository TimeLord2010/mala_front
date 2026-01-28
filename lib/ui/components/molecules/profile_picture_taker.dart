import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:awesome_flutter_extensions/awesome_flutter_extensions.dart';
import 'package:camera/camera.dart' as camera_package;
import 'package:camera_universal/camera_universal.dart';
import 'package:flutter/material.dart';
import 'package:mala_api/mala_api.dart';
import 'package:mala_front/data/errors/camera_exception.dart' as model;
import 'package:mala_front/ui/components/molecules/camera/processing_picture_overlay.dart';
import 'package:mala_front/ui/components/organisms/picture_taker_control_panel.dart';
import 'package:mala_front/ui/protocols/camera/get_camera_count.dart';
import 'package:mala_front/ui/protocols/invert_axis.dart';
import 'package:mala_front/ui/theme/text_styles/error_text_style.dart';
import 'package:mala_front/usecase/file/compress_image.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../theme/colors.dart';
import '../atoms/index.dart';

class ProfilePictureTaker extends StatefulWidget {
  const ProfilePictureTaker({super.key, required this.onPick});

  final void Function(Uint8List? bytes) onPick;

  @override
  State<StatefulWidget> createState() {
    return _ProfilePictureTakerState();
  }
}

class _ProfilePictureTakerState extends State<ProfilePictureTaker> {
  final _logger = createSdkLogger('ProfilePictureTaker');
  final cameraController = CameraController();
  int camerasCount = -1;
  int selectedIndex = 0;

  OverlayEntry? _overlayEntry;

  bool get isTakingPicture => _overlayEntry != null;
  set isTakingPicture(bool value) {
    if (value) {
      _overlayEntry = OverlayEntry(
        builder: (context) {
          return const ProcessingPictureOverlay();
        },
      );
      Overlay.of(context).insert(_overlayEntry!);
    } else {
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
  }

  @override
  void initState() {
    _logger.i('Init state profile picture');
    super.initState();
    unawaited(task());
  }

  Future<void> task() async {
    try {
      // Request camera permission
      var cameraStatus = await Permission.camera.status;
      if (!cameraStatus.isGranted) {
        cameraStatus = await Permission.camera.request();
        if (!cameraStatus.isGranted) {
          _logger.w('Camera permission denied');
          setState(() {
            this.camerasCount = 0;
          });
          return;
        }
      }

      // Get available cameras
      await cameraController.initializeCameras();

      var camerasCount = getCameraCount(cameraController);

      if (camerasCount == 0) {
        setState(() {
          this.camerasCount = 0;
        });
        _logger.w('No cameras found');
        return;
      }

      // Select fist camera
      await cameraController.initializeCamera(setState: setState);

      // Initialize selected camera
      await cameraController.activateCamera(
        setState: setState,
        mounted: () => mounted,
      );

      _logger.i('Camera count: $camerasCount');
      setState(() {
        this.camerasCount = camerasCount;
      });
    } on camera_package.CameraException catch (e) {
      _logger.e('Internal camera exception: (${e.code}) ${e.description}');
    } on model.CameraException catch (e) {
      _logger.e('Camera exception: $e');
    } on Exception catch (e) {
      _logger.e(getErrorMessage(e) ?? 'Camera initialization error');
    }
  }

  @override
  void dispose() {
    _logger.i('[PictureTaker] dispose');
    if (Platform.isWindows) {
      var cameraId = cameraController.camera_id;
      if (cameraId != 0) {
        _logger.i('Disposing of camereId $cameraId');
        unawaited(cameraController.camera_windows.dispose(cameraId));
      }
    }
    unawaited(cameraController.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          var width = constraints.maxWidth;
          var direction = width > 600 ? Axis.horizontal : Axis.vertical;
          double controlPanelSize = 60;
          return Flex(
            direction: direction,
            children: [
              Expanded(child: _cameraFrame()),
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
                  onPictureTaken: (path) async {
                    if (isTakingPicture) return;
                    isTakingPicture = true;
                    try {
                      if (path == null) {
                        widget.onPick(null);
                        return;
                      }
                      var file = File(path);
                      var compressed = await compressImage(
                        file,
                        quality: 10,
                        minimumSizeInKb: 64,
                      );
                      if (!compressed.compressed) {
                        debugPrint('did not compress');
                      } else {
                        var bytes = compressed.output.lengthInBytes ~/ 1024;
                        var originalSize = compressed.originalSize ~/ 1024;
                        debugPrint('compresssed: $bytes / $originalSize kb');
                      }
                      widget.onPick(compressed.output);
                      context.navigator.pop();
                    } finally {
                      isTakingPicture = false;
                    }
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _cameraMessage(String message) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: MalaText(
        message,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _cameraFrame() {
    if (camerasCount == -1) {
      return _cameraMessage('Carregando...');
    }
    if (camerasCount == 0) {
      return _cameraMessage('Nenhuma camera encontrada.');
    }
    return Camera(
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
    );
  }
}
