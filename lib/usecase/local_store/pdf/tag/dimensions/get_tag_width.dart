import 'package:mala_front/data/entities/index.dart';
import 'package:mala_front/usecase/local_store/pdf/tag/get_tag_value.dart';

double getTagWidth() {
  return getTagValue(LocalKeys.pdfTagWidth, 280.77165);
}
