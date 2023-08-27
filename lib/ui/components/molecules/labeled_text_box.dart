import 'package:fluent_ui/fluent_ui.dart';
import 'package:mala_front/ui/components/atoms/mouse_hover.dart';

class LabeledTextBox extends StatefulWidget {
  LabeledTextBox({
    super.key,
    required this.label,
    this.canClear = true,
    TextEditingController? controller,
  }) : controller = controller ?? TextEditingController();

  final String label;
  final bool canClear;
  final TextEditingController controller;

  @override
  State<StatefulWidget> createState() {
    return LabeledTextBoxState();
  }
}

class LabeledTextBoxState extends State<LabeledTextBox> {
  bool _isEmpty = true;
  bool get isEmpty => _isEmpty;
  set isEmpty(bool value) {
    if (value == _isEmpty) return;
    setState(() {
      _isEmpty = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    var infoLabel = InfoLabel(
      label: widget.label,
      child: TextBox(
        controller: widget.controller,
        onChanged: (value) {
          isEmpty = value.isEmpty;
        },
      ),
    );
    if (!widget.canClear) {
      return infoLabel;
    }
    return LimitedBox(
      maxHeight: 50,
      child: MouseHover(
        builder: (isMouseOver) {
          return Stack(
            children: [
              Positioned.fill(
                child: infoLabel,
              ),
              Positioned(
                right: 3,
                bottom: 1,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: (isMouseOver && !isEmpty) ? 1 : 0,
                  child: IconButton(
                    icon: Icon(
                      FluentIcons.chrome_close,
                      color: Colors.grey[100],
                    ),
                    onPressed: () {
                      widget.controller.clear();
                      isEmpty = true;
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
