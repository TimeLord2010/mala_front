import 'package:flutter/widgets.dart';
import 'package:mala_api/mala_api.dart';
import 'package:mala_front/ui/components/molecules/settings_pane/tag/tag_fields.dart';

class TagMargins extends StatelessWidget {
  /// Configuration for the tag page margins
  const TagMargins({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TagFields(
            title: 'Margens da página',
            topLabel: 'Esquerda',
            bottomLabel: 'Direita',
            topGetter: () => MalaApi.tagPdfConfig.tagLeftMargin,
            topSetter: MalaApi.tagPdfConfig.setTagLeftMargin,
            bottomGetter: () => MalaApi.tagPdfConfig.tagRightMargin,
            bottomSetter: MalaApi.tagPdfConfig.setTagRightMargin,
          ),
        ),
        const SizedBox(width: 5),
        Expanded(
          child: TagFields(
            title: '',
            topLabel: 'Cima',
            bottomLabel: 'Baixo',
            topGetter: () => MalaApi.tagPdfConfig.tagTopMargin,
            topSetter: MalaApi.tagPdfConfig.setTagTopMargin,
            bottomGetter: () => MalaApi.tagPdfConfig.tagBottomMargin,
            bottomSetter: MalaApi.tagPdfConfig.setTagBottomMargin,
          ),
        ),
      ],
    );
  }
}
