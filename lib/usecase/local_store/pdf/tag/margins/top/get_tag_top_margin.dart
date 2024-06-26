import 'package:mala_front/models/enums/local_keys.dart';
import 'package:mala_front/usecase/local_store/pdf/tag/get_tag_value.dart';

double getTagTopMargin() {
  return getTagValue(LocalKeys.pdfTagTopMargin, 14.17322);
}
