import 'package:flutter/widgets.dart';
import 'package:mala_front/ui/components/molecules/settings_pane/tag/tag_fields.dart';
import 'package:mala_front/usecase/local_store/pdf/tag/spacings/get_tag_horizontal_spacing.dart';
import 'package:mala_front/usecase/local_store/pdf/tag/spacings/get_tag_vertical_spacing.dart';
import 'package:mala_front/usecase/local_store/pdf/tag/spacings/set_tag_horizontal_spacing.dart';
import 'package:mala_front/usecase/local_store/pdf/tag/spacings/set_tag_vertical_spacing.dart';

class TagSpacings extends StatelessWidget {
  /// Configuration for the space around each tag.
  const TagSpacings({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const TagFields(
      title: 'Espaçamentos',
      topLabel: 'Horizontal',
      bottomLabel: 'Vertical',
      topGetter: getTagHorizontalSpacing,
      topSetter: setTagHorizontalSpacing,
      bottomGetter: getTagVerticalSpacing,
      bottomSetter: setTagVerticalSpacing,
    );
  }
}
