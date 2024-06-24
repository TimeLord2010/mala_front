import 'package:flutter/widgets.dart';
import 'package:mala_front/ui/components/molecules/settings_pane/tag/tag_fields.dart';
import 'package:mala_front/usecase/local_store/pdf/tag/dimensions/get_tag_height.dart';
import 'package:mala_front/usecase/local_store/pdf/tag/dimensions/get_tag_width.dart';
import 'package:mala_front/usecase/local_store/pdf/tag/dimensions/set_tag_height.dart';
import 'package:mala_front/usecase/local_store/pdf/tag/dimensions/set_tag_width.dart';

class TagDimensions extends StatelessWidget {
  /// Configuration for the dimensions of each tag.
  const TagDimensions({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const TagFields(
      title: 'Dimensões',
      topLabel: 'Largura',
      bottomLabel: 'Altura',
      topGetter: getTagWidth,
      topSetter: setTagWidth,
      bottomGetter: getTagHeight,
      bottomSetter: setTagHeight,
    );
  }
}
