import 'package:awesome_flutter_extensions/awesome_flutter_extensions.dart';
import 'package:flutter/material.dart';
import 'package:mala_front/ui/components/atoms/page_button.dart';

class PageSelector extends StatelessWidget {
  const PageSelector({
    super.key,
    required this.index,
    required this.pages,
    required this.onSelected,
    this.buttonSize = 25,
  });

  final int pages;
  final int index;
  final double buttonSize;
  final void Function(int) onSelected;

  @override
  Widget build(BuildContext context) {
    var list = [
      _item(index - 9),
      if (index >= 9) const Text('...'),
      _item(index - 3),
      _item(index - 2),
      _item(index - 1),
      _item(index),
      _item(index + 1),
      _item(index + 2),
      _item(index + 3),
      if (pages - index > 9) const Text('...'),
      _item(index + 9),
    ].whereType<Widget>().toList();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: 30,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: list.separatedBy(const SizedBox(width: 10)),
        ),
      ),
    );
  }

  Widget? _item(int pageIndex) {
    if (pageIndex < 0 || pageIndex >= pages) {
      return null;
    }
    var isSelected = pageIndex == index;
    return PageButton(
      onSelection: () {
        onSelected(pageIndex);
      },
      size: buttonSize,
      selected: isSelected,
      child: Text(
        (pageIndex + 1).toString(),
        style: TextStyle(
          color: isSelected ? const Color.fromARGB(255, 255, 255, 255) : const Color.fromARGB(255, 0, 0, 0),
        ),
      ),
    );
  }
}
