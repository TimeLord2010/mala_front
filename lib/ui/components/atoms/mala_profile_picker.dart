import 'dart:io';

import 'package:awesome_flutter_extensions/awesome_flutter_extensions.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:mala_front/ui/components/molecules/profile_picture_taker.dart';
import 'package:mala_front/usecase/error/get_error_message.dart';
import 'package:mala_front/usecase/file/pick_image.dart';
import 'package:vit/vit.dart';

class MalaProfilePicker extends StatelessWidget {
  const MalaProfilePicker({
    super.key,
    this.letters,
    this.bytes,
    this.onPick,
    this.size = 40,
    this.onRenderError,
  });

  final String? letters;
  final Uint8List? bytes;
  final void Function(Uint8List? bytes)? onPick;
  final void Function()? onRenderError;
  final double size;

  @override
  Widget build(BuildContext context) {
    final pick = onPick;
    if (pick == null) {
      return _frame();
    }
    return GestureDetector(
      onTap: () async {
        // TODO: Remove
        if (kDebugMode) {
          context.navigator.pushMaterial(const ProfilePictureTaker());
          return;
        }
        var path = await pickImage();
        if (path == null) {
          pick(null);
          return;
        }
        var compressed = await compressImage(
          File(path),
          quality: 30,
          minimumSizeInKb: 128,
        );
        if (!compressed.compressed) {
          debugPrint('did not compress');
        } else {
          var bytes = compressed.output.lengthInBytes ~/ 1024;
          debugPrint('compresssed: $bytes kb');
        }
        pick(compressed.output);
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: _frame(),
      ),
    );
  }

  ImageProvider? get imageProvider {
    if (bytes != null) {
      return MemoryImage(bytes!);
    }
    return null;
  }

  Widget _frame() {
    var imageProvider2 = imageProvider;
    return FittedBox(
      child: CircleAvatar(
        foregroundImage: imageProvider2,
        radius: size / 2,
        onForegroundImageError: imageProvider2 == null
            ? null
            : (exception, stackTrace) {
                logError('Failed to load image: ${getErrorMessage(exception)}');
                onRenderError?.call();
              },
        child: _child(),
      ),
    );
  }

  Widget _child() {
    if (letters != null) {
      return Center(
        child: Text(letters!),
      );
    }
    return Icon(
      FluentIcons.contact,
      size: size / 2,
    );
  }
}
