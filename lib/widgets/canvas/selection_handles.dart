import 'package:flutter/material.dart';
import '../../models/canvas_element.dart';

/// Widget that displays selection handles around selected elements
class SelectionHandles extends StatefulWidget {
  final CanvasElement element;
  final Function(Size) onResize;
  final Function(double) onRotate;
  final Function(Offset) onMove;

  const SelectionHandles({
    super.key,
    required this.element,
    required this.onResize,
    required this.onRotate,
    required this.onMove,
  });

  @override
  State<SelectionHandles> createState() => _SelectionHandlesState();
}

class _SelectionHandlesState extends State<SelectionHandles> {
  static const double handleSize = 8.0;
  static const double rotationHandleDistance = 20.0;
  
  late Size currentSize;
  late double currentRotation;

  @override
  void initState() {
    super.initState();
    currentSize = widget.element.size;
    currentRotation = widget.element.rotation;
  }

  @override
  void didUpdateWidget(SelectionHandles oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.element != widget.element) {
      currentSize = widget.element.size;
      currentRotation = widget.element.rotation;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Selection border
        Container(
          width: currentSize.width,
          height: currentSize.height,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.blue,
              width: 1.5,
            ),
          ),
        ),

        // Corner resize handles
        _buildCornerHandle(Alignment.topLeft, _HandleType.topLeft),
        _buildCornerHandle(Alignment.topRight, _HandleType.topRight),
        _buildCornerHandle(Alignment.bottomLeft, _HandleType.bottomLeft),
        _buildCornerHandle(Alignment.bottomRight, _HandleType.bottomRight),

        // Edge resize handles (for non-line elements)
        if (widget.element.type != ElementType.line) ...[
          _buildEdgeHandle(Alignment.topCenter, _HandleType.top),
          _buildEdgeHandle(Alignment.bottomCenter, _HandleType.bottom),
          _buildEdgeHandle(Alignment.centerLeft, _HandleType.left),
          _buildEdgeHandle(Alignment.centerRight, _HandleType.right),
        ],

        // Rotation handle
        _buildRotationHandle(),
      ],
    );
  }

  Widget _buildCornerHandle(Alignment alignment, _HandleType handleType) {
    return Positioned.fromRect(
      rect: _getHandleRect(alignment),
      child: GestureDetector(
        onPanUpdate: (details) => _handleResize(details.delta, handleType),
        onPanEnd: (details) => _onResizeEnd(),
        child: Container(
          width: handleSize,
          height: handleSize,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.blue, width: 1),
            borderRadius: BorderRadius.circular(1),
          ),
          child: MouseRegion(
            cursor: _getCursorForHandle(handleType),
            child: Container(),
          ),
        ),
      ),
    );
  }

  Widget _buildEdgeHandle(Alignment alignment, _HandleType handleType) {
    return Positioned.fromRect(
      rect: _getHandleRect(alignment),
      child: GestureDetector(
        onPanUpdate: (details) => _handleResize(details.delta, handleType),
        onPanEnd: (details) => _onResizeEnd(),
        child: Container(
          width: handleSize,
          height: handleSize,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.blue, width: 1),
            borderRadius: BorderRadius.circular(1),
          ),
          child: MouseRegion(
            cursor: _getCursorForHandle(handleType),
            child: Container(),
          ),
        ),
      ),
    );
  }

  Widget _buildRotationHandle() {
    return Positioned(
      left: currentSize.width / 2 - handleSize / 2,
      top: -rotationHandleDistance - handleSize / 2,
      child: GestureDetector(
        onPanUpdate: (details) => _handleRotation(details.localPosition),
        onPanEnd: (details) => _onRotationEnd(),
        child: Container(
          width: handleSize,
          height: handleSize,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.blue, width: 1),
            borderRadius: BorderRadius.circular(handleSize / 2),
          ),
          child: const Icon(
            Icons.rotate_right,
            size: handleSize - 2,
            color: Colors.blue,
          ),
        ),
      ),
    );
  }

  Rect _getHandleRect(Alignment alignment) {
    final centerX = currentSize.width / 2;
    final centerY = currentSize.height / 2;
    
    double left, top;
    
    switch (alignment) {
      case Alignment.topLeft:
        left = -handleSize / 2;
        top = -handleSize / 2;
        break;
      case Alignment.topCenter:
        left = centerX - handleSize / 2;
        top = -handleSize / 2;
        break;
      case Alignment.topRight:
        left = currentSize.width - handleSize / 2;
        top = -handleSize / 2;
        break;
      case Alignment.centerLeft:
        left = -handleSize / 2;
        top = centerY - handleSize / 2;
        break;
      case Alignment.centerRight:
        left = currentSize.width - handleSize / 2;
        top = centerY - handleSize / 2;
        break;
      case Alignment.bottomLeft:
        left = -handleSize / 2;
        top = currentSize.height - handleSize / 2;
        break;
      case Alignment.bottomCenter:
        left = centerX - handleSize / 2;
        top = currentSize.height - handleSize / 2;
        break;
      case Alignment.bottomRight:
        left = currentSize.width - handleSize / 2;
        top = currentSize.height - handleSize / 2;
        break;
      default:
        left = 0;
        top = 0;
    }

    return Rect.fromLTWH(left, top, handleSize, handleSize);
  }

  void _handleResize(Offset delta, _HandleType handleType) {
    setState(() {
      switch (handleType) {
        case _HandleType.topLeft:
          currentSize = Size(
            (currentSize.width - delta.dx).clamp(20, double.infinity),
            (currentSize.height - delta.dy).clamp(20, double.infinity),
          );
          break;
        case _HandleType.topCenter:
        case _HandleType.top:
          currentSize = Size(
            currentSize.width,
            (currentSize.height - delta.dy).clamp(20, double.infinity),
          );
          break;
        case _HandleType.topRight:
          currentSize = Size(
            (currentSize.width + delta.dx).clamp(20, double.infinity),
            (currentSize.height - delta.dy).clamp(20, double.infinity),
          );
          break;
        case _HandleType.centerLeft:
        case _HandleType.left:
          currentSize = Size(
            (currentSize.width - delta.dx).clamp(20, double.infinity),
            currentSize.height,
          );
          break;
        case _HandleType.centerRight:
        case _HandleType.right:
          currentSize = Size(
            (currentSize.width + delta.dx).clamp(20, double.infinity),
            currentSize.height,
          );
          break;
        case _HandleType.bottomLeft:
          currentSize = Size(
            (currentSize.width - delta.dx).clamp(20, double.infinity),
            (currentSize.height + delta.dy).clamp(20, double.infinity),
          );
          break;
        case _HandleType.bottomCenter:
        case _HandleType.bottom:
          currentSize = Size(
            currentSize.width,
            (currentSize.height + delta.dy).clamp(20, double.infinity),
          );
          break;
        case _HandleType.bottomRight:
          currentSize = Size(
            (currentSize.width + delta.dx).clamp(20, double.infinity),
            (currentSize.height + delta.dy).clamp(20, double.infinity),
          );
          break;
      }
    });
  }

  void _handleRotation(Offset localPosition) {
    final center = Offset(currentSize.width / 2, currentSize.height / 2);
    final angle = (localPosition - center).direction;
    
    setState(() {
      currentRotation = angle;
    });
    
    widget.onRotate(currentRotation);
  }

  void _onResizeEnd() {
    widget.onResize(currentSize);
  }

  void _onRotationEnd() {
    // Rotation is already applied during gesture
  }

  MouseCursor _getCursorForHandle(_HandleType handleType) {
    switch (handleType) {
      case _HandleType.topLeft:
      case _HandleType.bottomRight:
        return SystemMouseCursors.resizeUpLeftDownRight;
      case _HandleType.topRight:
      case _HandleType.bottomLeft:
        return SystemMouseCursors.resizeUpRightDownLeft;
      case _HandleType.topCenter:
      case _HandleType.top:
      case _HandleType.bottomCenter:
      case _HandleType.bottom:
        return SystemMouseCursors.resizeUpDown;
      case _HandleType.centerLeft:
      case _HandleType.left:
      case _HandleType.centerRight:
      case _HandleType.right:
        return SystemMouseCursors.resizeLeftRight;
    }
  }
}

enum _HandleType {
  topLeft,
  topCenter,
  topRight,
  centerLeft,
  centerRight,
  bottomLeft,
  bottomCenter,
  bottomRight,
  top,
  bottom,
  left,
  right,
}
