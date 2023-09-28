import 'dart:typed_data';

import 'package:mala_front/usecase/patient/profile_picture/get_picture_file.dart';

Future<Uint8List?> loadProfilePicture(int patientId) async {
  var file = await getPictureFile(patientId);
  var exists = file.existsSync();
  if (exists) {
    return file.readAsBytes();
  }
  return null;
}
