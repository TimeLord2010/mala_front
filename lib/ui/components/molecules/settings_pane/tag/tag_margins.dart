import 'package:flutter/widgets.dart';
import 'package:mala_front/ui/components/molecules/settings_pane/tag/tag_fields.dart';
import 'package:mala_front/usecase/local_store/pdf/tag/margins/bottom/get_tag_bottom_margin.dart';
import 'package:mala_front/usecase/local_store/pdf/tag/margins/bottom/set_tag_bottom_margin.dart';
import 'package:mala_front/usecase/local_store/pdf/tag/margins/left/get_tag_left_margin.dart';
import 'package:mala_front/usecase/local_store/pdf/tag/margins/left/set_tag_left_margin.dart';
import 'package:mala_front/usecase/local_store/pdf/tag/margins/right/get_tag_right_margin.dart';
import 'package:mala_front/usecase/local_store/pdf/tag/margins/right/set_tag_right_margin.dart';
import 'package:mala_front/usecase/local_store/pdf/tag/margins/top/get_tag_top_margin.dart';
import 'package:mala_front/usecase/local_store/pdf/tag/margins/top/set_tag_top_margin.dart';

class TagMargins extends StatelessWidget {
  /// Configuration for the tag page margins
  const TagMargins({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: TagFields(
            title: 'Margens da página',
            topLabel: 'Esquerda',
            bottomLabel: 'Direita',
            topGetter: getTagLeftMargin,
            topSetter: setTagLeftMargin,
            bottomGetter: getTagRightMargin,
            bottomSetter: setTagRightMargin,
          ),
        ),
        SizedBox(width: 5),
        Expanded(
          child: TagFields(
            title: '',
            topLabel: 'Cima',
            bottomLabel: 'Baixo',
            topGetter: getTagTopMargin,
            topSetter: setTagTopMargin,
            bottomGetter: getTagBottomMargin,
            bottomSetter: setTagBottomMargin,
          ),
        ),
      ],
    );
  }
}
