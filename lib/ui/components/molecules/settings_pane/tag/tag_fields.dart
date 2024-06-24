import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:mala_front/ui/components/molecules/labeled_text_box.dart';

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

  @override
  void initState() {
    super.initState();
    _topController.text = widget.topGetter().toString();
    _bottomController.text = widget.bottomGetter().toString();
  }

  @override
  void dispose() {
    super.dispose();

    // Saving the inputed variables

    // Top
    var topValue = double.tryParse(_topController.text);
    unawaited(widget.topSetter(topValue));

    // Bottom
    var bottomValue = double.tryParse(_bottomController.text);
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
        ),
        const SizedBox(height: 8),
        LabeledTextBox(
          label: widget.bottomLabel,
          controller: _bottomController,
        )
      ],
    );
  }
}
