import 'package:flutter/material.dart';

import '../../../data/enums/activities.dart';
import '../atoms/mala_check_box.dart';

class ActivitiesSelector extends StatefulWidget {
  const ActivitiesSelector({
    super.key,
    required this.selected,
  });

  final Set<Activities> selected;

  @override
  State<ActivitiesSelector> createState() => _ActivitiesSelectorState();
}

class _ActivitiesSelectorState extends State<ActivitiesSelector> {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: Activities.values.map((x) {
        return Padding(
          padding: const EdgeInsets.all(4),
          child: SizedBox(
            width: 135,
            child: Align(
              alignment: Alignment.centerLeft,
              child: MalaCheckBox(
                label: x.toString(),
                checked: widget.selected.contains(x),
                onCheck: (checked) {
                  if (checked) {
                    setState(() {
                      widget.selected.add(x);
                    });
                  } else {
                    setState(() {
                      widget.selected.remove(x);
                    });
                  }
                },
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
