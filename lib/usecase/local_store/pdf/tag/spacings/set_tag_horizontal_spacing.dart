import 'package:mala_front/models/index.dart';
import 'package:mala_front/usecase/local_store/pdf/tag/set_tag_value.dart';

Future<void> setTagHorizontalSpacing(double? value) async {
  await setTagValue(
    minimum: 0,
    maximum: 100,
    key: LocalKeys.pdfTagHorizontalSpacing,
    logKey: 'setTagHorizontalSpacing',
    value: value,
  );
}
