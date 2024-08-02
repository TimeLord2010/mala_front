import 'package:mala_front/data/entities/index.dart';
import 'package:mala_front/usecase/local_store/pdf/tag/set_tag_value.dart';

Future<void> setTagBottomMargin(double? value) async {
  await setTagValue(
    key: LocalKeys.pdfTagBottomMargin,
    logKey: 'setTagBottomMargin',
    minimum: 0,
    maximum: 100,
    value: value,
  );
}
