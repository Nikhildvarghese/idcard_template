import 'package:flutter/material.dart';
import '../../models/canvas_element.dart';

class TextEditingWidget extends StatefulWidget {
  final TextElement element;
  final ValueChanged<String> onTextChanged;
  final VoidCallback onEditingComplete;

  const TextEditingWidget({
    super.key,
    required this.element,
    required this.onTextChanged,
    required this.onEditingComplete,
  });

  @override
  State<TextEditingWidget> createState() => _TextEditingWidgetState();
}

class _TextEditingWidgetState extends State<TextEditingWidget> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.element.text);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      autofocus: true,
      decoration: const InputDecoration(
        isDense: true,
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
      style: TextStyle(
        fontFamily: widget.element.fontFamily,
        fontSize: widget.element.fontSize,
        color: widget.element.color,
        fontWeight: widget.element.fontWeight,
        fontStyle: widget.element.fontStyle,
        decoration: widget.element.textDecoration,
        letterSpacing: widget.element.letterSpacing,
        height: widget.element.lineHeight,
      ),
      textAlign: widget.element.textAlign,
      onChanged: widget.onTextChanged,
      onEditingComplete: widget.onEditingComplete,
    );
  }
}
