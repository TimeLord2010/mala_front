import 'package:mala_front/models/index.dart';
import 'package:mala_front/usecase/local_store/pdf/tag/set_tag_value.dart';

Future<void> setTagVerticalMargin(double? value) async {
  await setTagValue(
    key: LocalKeys.pdfTagVerticalMargin,
    logKey: 'setTagVerticalMargin',
    minimum: 0,
    maximum: 100,
    value: value,
  );
}
