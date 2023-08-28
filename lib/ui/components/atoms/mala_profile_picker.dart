import 'dart:io';
import 'dart:typed_data';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:mala_front/usecase/file/pick_image.dart';
import 'package:vit/vit.dart';

class MalaProfilePicker extends StatefulWidget {
  const MalaProfilePicker({
    super.key,
    this.letters,
    this.localPath,
    this.onPick,
    this.size = 40,
  });

  final String? letters;
  final String? localPath;
  final void Function(String? path)? onPick;
  final double size;

  @override
  State<MalaProfilePicker> createState() => _MalaProfilePickerState();
}

class _MalaProfilePickerState extends State<MalaProfilePicker> {
  String? _currentPath;
  String? get currentPath => _currentPath;
  set currentPath(String? value) {
    _imageBytes = null;
    setState(() {
      _currentPath = value;
    });
  }

  Uint8List? _imageBytes;
  Uint8List? get imageBytes => _imageBytes;
  set imageBytes(Uint8List? value) {
    _currentPath = null;
    setState(() {
      _imageBytes = value;
    });
  }

  @override
  void initState() {
    super.initState();
    currentPath = widget.localPath;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.onPick == null) {
      return _frame();
    }
    return GestureDetector(
      onTap: () async {
        var path = await pickImage();
        if (path == null) {
          currentPath = path;
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
        imageBytes = compressed.output;
        //widget.onPick!(path);
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: _frame(),
      ),
    );
  }

  ImageProvider? get imageProvider {
    if (currentPath != null) {
      return FileImage(File(currentPath!));
    }
    if (imageBytes != null) {
      return MemoryImage(imageBytes!);
    }
    return null;
  }

  Widget _frame() {
    return FittedBox(
      child: CircleAvatar(
        foregroundImage: imageProvider,
        radius: widget.size / 2,
        child: _child(),
      ),
    );
  }

  Widget _child() {
    if (widget.letters != null) {
      return Center(
        child: Text(widget.letters!),
      );
    }
    return Icon(
      FluentIcons.contact,
      size: widget.size / 2,
    );
  }
}
