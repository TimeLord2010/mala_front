import 'package:vit/vit.dart';

Future<void> signout() async {
  await Vit().getSharedPreferences().clear();
}
