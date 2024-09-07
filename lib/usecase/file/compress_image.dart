import 'dart:io';
import 'dart:typed_data';

import 'package:image_compression/image_compression.dart';

Future<CompressionResult> compressImage(
  File file, {
  int quality = 50,
  int minimumSizeInKb = 512,
}) async {
  final content = await file.readAsBytes();
  final size = content.length;
  final kiloByteSize = size / 1024;
  if (kiloByteSize < minimumSizeInKb) {
    return CompressionResult.fromFile(file, content);
  }
  var config = Configuration(
    outputType: OutputType.jpg,

    // set quality between 0-100
    jpgQuality: quality,
  );

  final input = ImageFile(
    filePath: file.path,
    rawBytes: content,
  );
  final param = ImageFileConfiguration(input: input, config: config);
  final output = await compressInQueue(param);

  return CompressionResult(
    input: file,
    output: output.rawBytes,
    originalSize: size,
  );
}

class CompressionResult {
  final File input;
  final Uint8List output;
  final int originalSize;
  final bool compressed;

  CompressionResult({
    required this.input,
    required this.output,
    required this.originalSize,
    this.compressed = true,
  });

  factory CompressionResult.fromFile(File input, [Uint8List? content]) {
    content ??= input.readAsBytesSync();
    return CompressionResult(
      input: input,
      output: content,
      originalSize: content.length,
      compressed: false,
    );
  }

  int get savedBytes {
    return originalSize - output.length;
  }
}
