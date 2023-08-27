import 'package:flutter/material.dart';

class MouseHover extends StatefulWidget {
  const MouseHover({
    super.key,
    required this.builder,
  });

  final Widget Function(bool isMouseOver) builder;

  @override
  State<MouseHover> createState() => _MouseHoverState();
}

class _MouseHoverState extends State<MouseHover> {
  bool _isMouseOver = false;
  bool get isMouseOver => _isMouseOver;
  set isMouseOver(bool value) {
    setState(() {
      _isMouseOver = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        isMouseOver = true;
      },
      onExit: (_) {
        isMouseOver = false;
      },
      child: widget.builder(isMouseOver),
    );
  }
}
