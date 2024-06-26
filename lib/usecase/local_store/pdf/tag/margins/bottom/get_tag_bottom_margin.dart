import 'package:mala_front/models/index.dart';
import 'package:mala_front/usecase/local_store/pdf/tag/get_tag_value.dart';

double getTagBottomMargin() {
  return getTagValue(LocalKeys.pdfTagBottomMargin, 14.17322);
}
