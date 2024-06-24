import 'package:flutter/widgets.dart';
import 'package:mala_front/ui/components/molecules/settings_pane/tag/tag_fields.dart';
import 'package:mala_front/usecase/local_store/pdf/tag/margins/get_tag_horizontal_margin.dart';
import 'package:mala_front/usecase/local_store/pdf/tag/margins/get_tag_vertical_margin.dart';
import 'package:mala_front/usecase/local_store/pdf/tag/margins/set_tag_horizontal_margin.dart';
import 'package:mala_front/usecase/local_store/pdf/tag/margins/set_tag_vertical_margin.dart';

class TagMargins extends StatelessWidget {
  /// Configuration for the tag page margins
  const TagMargins({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const TagFields(
      title: 'Margens da página',
      topLabel: 'Horizontal',
      bottomLabel: 'Vertical',
      topGetter: getTagHorizontalMargin,
      topSetter: setTagHorizontalMargin,
      bottomGetter: getTagVerticalMargin,
      bottomSetter: setTagVerticalMargin,
    );
  }
}
