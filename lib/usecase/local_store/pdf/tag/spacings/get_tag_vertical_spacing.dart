import 'package:mala_front/models/index.dart';
import 'package:mala_front/usecase/local_store/pdf/tag/get_tag_value.dart';

double getTagVerticalSpacing() {
  return getTagValue(LocalKeys.pdfTagVerticalSpacing, 0);
}
