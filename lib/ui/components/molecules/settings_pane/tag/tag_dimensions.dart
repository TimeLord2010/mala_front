import 'package:flutter/widgets.dart';
import 'package:mala_api/mala_api.dart';
import 'package:mala_front/ui/components/molecules/settings_pane/tag/tag_fields.dart';

class TagDimensions extends StatelessWidget {
  /// Configuration for the dimensions of each tag.
  const TagDimensions({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TagFields(
      title: 'Dimensões',
      topLabel: 'Largura',
      bottomLabel: 'Altura',
      topGetter: () => MalaApi.tagPdfConfig.tagWidth,
      topSetter: MalaApi.tagPdfConfig.setTagWidth,
      bottomGetter: () => MalaApi.tagPdfConfig.tagHeight,
      bottomSetter: MalaApi.tagPdfConfig.setTagHeight,
    );
  }
}
