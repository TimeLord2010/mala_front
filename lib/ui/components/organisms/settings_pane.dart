import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as material;
import 'package:mala_front/ui/components/molecules/settings_pane/tag/tag_dimensions.dart';
import 'package:mala_front/ui/components/molecules/settings_pane/tag/tag_margins.dart';
import 'package:mala_front/ui/components/molecules/settings_pane/tag/tag_spacings.dart';

class SettingsPane extends StatelessWidget {
  const SettingsPane({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          _tagsPanel(),
        ],
      ),
    );
  }

  SizedBox _tagsPanel() {
    return SizedBox(
      height: 180,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color.fromARGB(255, 157, 157, 157),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: _tagsFields(),
            ),
          ),
          Positioned(
            top: 0,
            left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 245, 245, 245),
              ),
              child: const Text('Etiquetas'),
            ),
          )
        ],
      ),
    );
  }

  Widget _tagsFields() {
    return const Row(
      children: [
        Expanded(
          child: TagDimensions(),
        ),
        material.VerticalDivider(),
        Expanded(
          child: TagSpacings(),
        ),
        material.VerticalDivider(),
        Expanded(
          flex: 2,
          child: TagMargins(),
        ),
      ],
    );
  }
}
