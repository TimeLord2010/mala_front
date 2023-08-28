import 'dart:io';
import 'dart:typed_data';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:mala_front/usecase/file/pick_image.dart';
import 'package:vit/vit.dart';

class MalaProfilePicker extends StatelessWidget {
  const MalaProfilePicker({
    super.key,
    this.letters,
    this.bytes,
    this.onPick,
    this.size = 40,
  });

  final String? letters;
  final Uint8List? bytes;
  final void Function(Uint8List? bytes)? onPick;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (onPick == null) {
      return _frame();
    }
    return GestureDetector(
      onTap: () async {
        var path = await pickImage();
        if (path == null) {
          onPick!(null);
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
        onPick!(compressed.output);
        //widget.onPick!(path);
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
    return FittedBox(
      child: CircleAvatar(
        foregroundImage: imageProvider,
        radius: size / 2,
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
