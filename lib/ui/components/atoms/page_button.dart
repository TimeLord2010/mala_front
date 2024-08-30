import 'package:fluent_ui/fluent_ui.dart';

class PageButton extends StatelessWidget {
  const PageButton({
    super.key,
    required this.child,
    this.selected = false,
    this.size = 25,
    required this.onSelection,
  });

  final Widget child;
  final bool selected;
  final double size;
  final void Function() onSelection;

  @override
  Widget build(BuildContext context) {
    var buttonStyle = const ButtonStyle(
      shape: WidgetStatePropertyAll(CircleBorder()),
    );
    var container = MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Container(
        decoration: _decoration(context),
        width: size,
        height: size,
        child: Center(
          child: child,
        ),
      ),
    );
    if (selected) {
      return FilledButton(
        onPressed: onSelection,
        style: buttonStyle,
        child: container,
      );
    } else {
      return Button(
        style: buttonStyle,
        onPressed: onSelection,
        child: container,
      );
    }
  }

  BoxDecoration? _decoration(BuildContext context) {
    //Color color = const Color.fromARGB(255, 2, 74, 134);
    if (!selected) {
      return const BoxDecoration(
        // border: Border.all(
        //   color: color,
        // ),
        shape: BoxShape.circle,
      );
    }
    return const BoxDecoration(
      shape: BoxShape.circle,
      //color: color,
    );
  }
}
