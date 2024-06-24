import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:mala_front/repositories/extensions/text_input_formatter.dart';
import 'package:mala_front/ui/components/molecules/labeled_text_box.dart';
import 'package:mask/mask.dart';

const int _multiplier = 10000;

class TagFields extends StatefulWidget {
  const TagFields({
    super.key,
    required this.title,
    required this.topLabel,
    required this.bottomLabel,
    required this.topGetter,
    required this.topSetter,
    required this.bottomGetter,
    required this.bottomSetter,
  });

  final String title, topLabel, bottomLabel;

  final double Function() topGetter;
  final double Function() bottomGetter;

  final Future<void> Function(double? value) topSetter;
  final Future<void> Function(double? value) bottomSetter;

  @override
  State<TagFields> createState() => _TagDimensionsState();
}

class _TagDimensionsState extends State<TagFields> {
  final _topController = TextEditingController();
  final _bottomController = TextEditingController();

  final _generic = Mask.generic(
    masks: ['###', '# ###', '## ###', '### ###', '# ### ###'],
  );

  @override
  void initState() {
    super.initState();
    String convert(double v) {
      var value = (v * _multiplier).round();
      return _generic.format(value.toString());
    }

    _topController.text = convert(widget.topGetter());
    _bottomController.text = convert(widget.bottomGetter());
  }

  @override
  void dispose() {
    super.dispose();

    double? valueGetter(TextEditingController controller) {
      var text = controller.text.replaceAll(' ', '');
      var integer = int.tryParse(text);
      if (integer == null) return null;
      return integer / _multiplier;
    }

    // Saving the inputed variables

    // Top
    var topValue = valueGetter(_topController);
    unawaited(widget.topSetter(topValue));

    // Bottom
    var bottomValue = valueGetter(_bottomController);
    unawaited(widget.bottomSetter(bottomValue));

    _topController.dispose();
    _bottomController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          widget.title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        LabeledTextBox(
          label: widget.topLabel,
          controller: _topController,
          formaters: [_generic],
        ),
        const SizedBox(height: 8),
        LabeledTextBox(
          label: widget.bottomLabel,
          controller: _bottomController,
          formaters: [_generic],
        )
      ],
    );
  }
}
