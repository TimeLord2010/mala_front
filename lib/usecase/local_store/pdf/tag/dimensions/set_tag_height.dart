import 'package:mala_front/models/index.dart';
import 'package:mala_front/usecase/local_store/pdf/tag/set_tag_value.dart';

/// Sets the tag height used in pdf generation in the local store.
Future<void> setTagHeight(double? value) async {
  await setTagValue(
    minimum: 10,
    maximum: 140,
    key: LocalKeys.pdfTagHeight,
    logKey: 'setTagHeight',
    value: value,
  );
}
