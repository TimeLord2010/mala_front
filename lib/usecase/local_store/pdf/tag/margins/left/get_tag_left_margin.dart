import 'package:mala_front/data/entities/index.dart';
import 'package:mala_front/usecase/local_store/pdf/tag/get_tag_value.dart';

double getTagLeftMargin() {
  return getTagValue(LocalKeys.pdfTagLeftMargin, 13.32283);
}
