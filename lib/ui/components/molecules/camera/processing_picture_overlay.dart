import 'package:flutter/material.dart';
import 'package:mala_front/ui/components/atoms/index.dart';

class ProcessingPictureOverlay extends StatelessWidget {
  const ProcessingPictureOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.white.withOpacity(0.7),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            MalaText('Processando imagem...'),
          ],
        ),
      ),
    );
  }
}
