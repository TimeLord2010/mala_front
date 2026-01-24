import 'package:awesome_flutter_extensions/awesome_flutter_extensions.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:mala_api/mala_api.dart';
import 'package:mala_front/ui/components/molecules/profile_picture_taker.dart';

final _logger = createSdkLogger('MalaProfilePicker');

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
        await context.navigator.pushMaterial(ProfilePictureTaker(
          onPick: pick,
        ));
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
                _logger
                    .e('Failed to load image: ${getErrorMessage(exception)}');
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
