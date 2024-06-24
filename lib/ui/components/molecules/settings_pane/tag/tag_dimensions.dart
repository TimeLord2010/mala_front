import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:mala_front/ui/components/molecules/labeled_text_box.dart';
import 'package:mala_front/usecase/local_store/pdf/tag/get_tag_height.dart';
import 'package:mala_front/usecase/local_store/pdf/tag/get_tag_width.dart';
import 'package:mala_front/usecase/local_store/pdf/tag/set_tag_height.dart';
import 'package:mala_front/usecase/local_store/pdf/tag/set_tag_width.dart';

class TagDimensions extends StatefulWidget {
  const TagDimensions({
    super.key,
  });

  @override
  State<TagDimensions> createState() => _TagDimensionsState();
}

class _TagDimensionsState extends State<TagDimensions> {
  final _widthController = TextEditingController();
  final _heightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _widthController.text = getTagWidth().toString();
    _heightController.text = getTagHeight().toString();
  }

  @override
  void dispose() {
    super.dispose();

    // Saving the inputed variables
    unawaited(setTagHeight(double.tryParse(_heightController.text) ?? 0));
    unawaited(setTagWidth(double.tryParse(_widthController.text) ?? 0));

    _widthController.dispose();
    _heightController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Dimensões',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        LabeledTextBox(
          label: 'Largura',
          controller: _widthController,
        ),
        const SizedBox(height: 8),
        LabeledTextBox(
          label: 'Altura',
          controller: _heightController,
        )
      ],
    );
  }
}
