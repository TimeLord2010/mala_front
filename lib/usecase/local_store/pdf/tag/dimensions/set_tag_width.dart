import 'package:mala_front/models/index.dart';
import 'package:mala_front/usecase/local_store/pdf/tag/set_tag_value.dart';

Future<void> setTagWidth(double? value) async {
  await setTagValue(
    minimum: 20,
    maximum: 600,
    key: LocalKeys.pdfTagWidth,
    logKey: 'setTagWidth',
    value: value,
  );
}
