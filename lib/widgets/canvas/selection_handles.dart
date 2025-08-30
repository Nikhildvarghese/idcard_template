import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../../models/canvas_element.dart';
import 'mobile_resize_helper.dart';

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
  // Mobile-optimized handle sizes - increased for better interaction
  static const double handleVisualSize = 14.0; // Visual size (increased from 10.0)
  static const double handleTouchSize = 40.0;   // Touch area size (increased from 32.0)
  static const double rotationHandleDistance = 35.0;
  
  late Size currentSize;
  late double currentRotation;
  
  // Track which handle is being touched for feedback
  _HandleType? _activeTouchHandle;
  bool _isResizing = false;
  
  // Platform-specific settings
  bool get _isMobile => !kIsWeb && (Theme.of(context).platform == TargetPlatform.android || Theme.of(context).platform == TargetPlatform.iOS);

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
        // Selection border with double-tap for mobile resize helper
        GestureDetector(
          onDoubleTap: _isMobile ? () => _showMobileResizeHelper(context) : null,
          child: Container(
            width: currentSize.width,
            height: currentSize.height,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.blue,
                width: 1.5,
              ),
            ),
            // Removed mobile touch hint as it was causing visual confusion
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
    final handleRect = _getHandleRect(alignment);
    final isActive = _activeTouchHandle == handleType;
    
    return Positioned.fromRect(
      rect: _getTouchRect(alignment), // Use larger touch area
      child: GestureDetector(
        onPanStart: (details) => _onPanStart(handleType),
        onPanUpdate: (details) => _handleResize(details.delta, handleType),
        onPanEnd: (details) => _onPanEnd(),
        child: Container(
          width: handleTouchSize,
          height: handleTouchSize,
          color: Colors.transparent, // Invisible touch area
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              width: isActive ? handleVisualSize + 4 : handleVisualSize,
              height: isActive ? handleVisualSize + 4 : handleVisualSize,
              decoration: BoxDecoration(
                color: isActive ? Colors.blue.shade100 : Colors.white,
                border: Border.all(
                  color: isActive ? Colors.blue.shade700 : Colors.blue, 
                  width: isActive ? 2 : 1.5,
                ),
                borderRadius: BorderRadius.circular(2),
                boxShadow: isActive ? [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ] : null,
              ),
              child: MouseRegion(
                cursor: _getCursorForHandle(handleType),
                child: Container(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEdgeHandle(Alignment alignment, _HandleType handleType) {
    final isActive = _activeTouchHandle == handleType;
    
    return Positioned.fromRect(
      rect: _getTouchRect(alignment),
      child: GestureDetector(
        onPanStart: (details) => _onPanStart(handleType),
        onPanUpdate: (details) => _handleResize(details.delta, handleType),
        onPanEnd: (details) => _onPanEnd(),
        child: Container(
          width: handleTouchSize,
          height: handleTouchSize,
          color: Colors.transparent,
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              width: isActive ? handleVisualSize + 4 : handleVisualSize,
              height: isActive ? handleVisualSize + 4 : handleVisualSize,
              decoration: BoxDecoration(
                color: isActive ? Colors.blue.shade100 : Colors.white,
                border: Border.all(
                  color: isActive ? Colors.blue.shade700 : Colors.blue, 
                  width: isActive ? 2 : 1.5,
                ),
                borderRadius: BorderRadius.circular(2),
                boxShadow: isActive ? [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ] : null,
              ),
              child: MouseRegion(
                cursor: _getCursorForHandle(handleType),
                child: Container(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRotationHandle() {
    final isActive = _activeTouchHandle == null && _isResizing; // Active during rotation
    
    return Positioned(
      left: currentSize.width / 2 - handleTouchSize / 2,
      top: -rotationHandleDistance - handleTouchSize / 2,
      child: GestureDetector(
        onPanStart: (details) => _onRotationStart(),
        onPanUpdate: (details) => _handleRotation(details.localPosition),
        onPanEnd: (details) => _onRotationEnd(),
        child: Container(
          width: handleTouchSize,
          height: handleTouchSize,
          color: Colors.transparent,
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              width: isActive ? handleVisualSize + 6 : handleVisualSize + 2,
              height: isActive ? handleVisualSize + 6 : handleVisualSize + 2,
              decoration: BoxDecoration(
                color: isActive ? Colors.green.shade100 : Colors.white,
                border: Border.all(
                  color: isActive ? Colors.green.shade700 : Colors.blue, 
                  width: isActive ? 2 : 1.5,
                ),
                borderRadius: BorderRadius.circular((handleVisualSize + 2) / 2),
                boxShadow: isActive ? [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ] : null,
              ),
              child: Icon(
                Icons.rotate_right,
                size: handleVisualSize - 2,
                color: isActive ? Colors.green.shade700 : Colors.blue,
              ),
            ),
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
        left = -handleVisualSize / 2;
        top = -handleVisualSize / 2;
        break;
      case Alignment.topCenter:
        left = centerX - handleVisualSize / 2;
        top = -handleVisualSize / 2;
        break;
      case Alignment.topRight:
        left = currentSize.width - handleVisualSize / 2;
        top = -handleVisualSize / 2;
        break;
      case Alignment.centerLeft:
        left = -handleVisualSize / 2;
        top = centerY - handleVisualSize / 2;
        break;
      case Alignment.centerRight:
        left = currentSize.width - handleVisualSize / 2;
        top = centerY - handleVisualSize / 2;
        break;
      case Alignment.bottomLeft:
        left = -handleVisualSize / 2;
        top = currentSize.height - handleVisualSize / 2;
        break;
      case Alignment.bottomCenter:
        left = centerX - handleVisualSize / 2;
        top = currentSize.height - handleVisualSize / 2;
        break;
      case Alignment.bottomRight:
        left = currentSize.width - handleVisualSize / 2;
        top = currentSize.height - handleVisualSize / 2;
        break;
      default:
        left = 0;
        top = 0;
    }

    return Rect.fromLTWH(left, top, handleVisualSize, handleVisualSize);
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
    setState(() {
      _isResizing = false;
    });
    // Add haptic feedback on mobile
    if (_isMobile) {
      HapticFeedback.lightImpact();
    }
  }
  
  // Touch interaction methods
  void _onPanStart(_HandleType handleType) {
    setState(() {
      _activeTouchHandle = handleType;
      _isResizing = true;
    });
    // Add haptic feedback on mobile
    if (_isMobile) {
      HapticFeedback.lightImpact();
    }
  }
  
  void _onPanEnd() {
    setState(() {
      _activeTouchHandle = null;
      _isResizing = false;
    });
    _onResizeEnd();
    // Add haptic feedback on mobile
    if (_isMobile) {
      HapticFeedback.lightImpact();
    }
  }
  
  void _onRotationStart() {
    setState(() {
      _isResizing = true;
    });
    // Add haptic feedback on mobile
    if (_isMobile) {
      HapticFeedback.lightImpact();
    }
  }
  
  // Create larger touch rectangle for better mobile interaction
  Rect _getTouchRect(Alignment alignment) {
    final centerX = currentSize.width / 2;
    final centerY = currentSize.height / 2;
    
    double left, top;
    
    switch (alignment) {
      case Alignment.topLeft:
        left = -handleTouchSize / 2;
        top = -handleTouchSize / 2;
        break;
      case Alignment.topCenter:
        left = centerX - handleTouchSize / 2;
        top = -handleTouchSize / 2;
        break;
      case Alignment.topRight:
        left = currentSize.width - handleTouchSize / 2;
        top = -handleTouchSize / 2;
        break;
      case Alignment.centerLeft:
        left = -handleTouchSize / 2;
        top = centerY - handleTouchSize / 2;
        break;
      case Alignment.centerRight:
        left = currentSize.width - handleTouchSize / 2;
        top = centerY - handleTouchSize / 2;
        break;
      case Alignment.bottomLeft:
        left = -handleTouchSize / 2;
        top = currentSize.height - handleTouchSize / 2;
        break;
      case Alignment.bottomCenter:
        left = centerX - handleTouchSize / 2;
        top = currentSize.height - handleTouchSize / 2;
        break;
      case Alignment.bottomRight:
        left = currentSize.width - handleTouchSize / 2;
        top = currentSize.height - handleTouchSize / 2;
        break;
      default:
        left = 0;
        top = 0;
    }
    
    return Rect.fromLTWH(left, top, handleTouchSize, handleTouchSize);
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
  
  /// Show mobile-friendly resize helper dialog
  void _showMobileResizeHelper(BuildContext context) {
    HapticFeedback.mediumImpact();
    showMobileResizeHelper(
      context: context,
      element: widget.element,
      onResize: (newSize) {
        setState(() {
          currentSize = newSize;
        });
        widget.onResize(newSize);
      },
    );
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
