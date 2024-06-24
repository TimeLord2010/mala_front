import 'package:mala_front/models/index.dart';
import 'package:mala_front/usecase/local_store/pdf/tag/get_tag_value.dart';

double getTagHeight() {
  return getTagValue(LocalKeys.pdfTagHeight, 73.95848);
}
