import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:id_card_designer/models/canvas_state.dart';
import 'dart:io';
import 'dart:math' as math;
import '../../models/canvas_element.dart';
import '../../providers/canvas_provider.dart';
import 'text_editing_widget.dart';

/// Widget that renders different types of canvas elements
class ElementRenderer extends ConsumerWidget {
  final CanvasElement element;

  const ElementRenderer({
    super.key,
    required this.element,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canvasState = ref.watch(canvasProvider);
    
    switch (element.type) {
      case ElementType.text:
        return _renderTextElement(
          element as TextElement,
          canvasState,
          ref,
        );
      case ElementType.image:
        return _renderImageElement(element as ImageElement);
      case ElementType.shape:
        return _renderShapeElement(element as ShapeElement);
      case ElementType.line:
        return _renderLineElement(element as LineElement);
      case ElementType.background:
        return _renderBackgroundElement(element as BackgroundElement);
    }
  }

  Widget _renderTextElement(TextElement element, CanvasState canvasState, WidgetRef ref) {
    final isEditing = canvasState.editingTextElementId == element.id;
    final canvasNotifier = ref.read(canvasProvider.notifier);
    
    return Container(
      width: element.size.width,
      height: element.size.height,
      decoration: element.isSelected
          ? BoxDecoration(
              border: Border.all(color: Colors.blue, width: 2),
            )
          : null,
      child: isEditing
          ? TextEditingWidget(
              element: element,
              onTextChanged: (newText) {
                canvasNotifier.updateEditingText(newText);
              },
              onEditingComplete: () {
                canvasNotifier.stopTextEditing();
              },
            )
          : Text(
              element.text,
              style: TextStyle(
                fontFamily: element.fontFamily,
                fontSize: element.fontSize,
                color: element.color,
                fontWeight: element.fontWeight,
                fontStyle: element.fontStyle,
                decoration: element.textDecoration,
                letterSpacing: element.letterSpacing,
                height: element.lineHeight,
              ),
              textAlign: element.textAlign,
              overflow: TextOverflow.visible,
            ),
    );
  }

  Widget _renderImageElement(ImageElement element) {
    Widget imageWidget;

    if (element.imagePath.startsWith('http')) {
      // Network image
      imageWidget = Image.network(
        element.imagePath,
        width: element.size.width,
        height: element.size.height,
        fit: element.fit,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: element.size.width,
            height: element.size.height,
            color: Colors.grey.shade200,
            child: const Icon(
              Icons.broken_image,
              color: Colors.grey,
              size: 50,
            ),
          );
        },
      );
    } else {
      // Local file image
      final file = File(element.imagePath);
      if (file.existsSync()) {
        imageWidget = Image.file(
          file,
          width: element.size.width,
          height: element.size.height,
          fit: element.fit,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: element.size.width,
              height: element.size.height,
              color: Colors.grey.shade200,
              child: const Icon(
                Icons.broken_image,
                color: Colors.grey,
                size: 50,
              ),
            );
          },
        );
      } else {
        // Placeholder for non-existent file
        imageWidget = Container(
          width: element.size.width,
          height: element.size.height,
          color: Colors.grey.shade200,
          child: const Icon(
            Icons.image,
            color: Colors.grey,
            size: 50,
          ),
        );
      }
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(element.borderRadius),
        border: element.borderColor != null
            ? Border.all(
                color: element.borderColor!,
                width: element.borderWidth,
              )
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(element.borderRadius),
        child: Stack(
          children: [
            imageWidget,
            if (element.isSelected)
              Container(
                width: element.size.width,
                height: element.size.height,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue, width: 2),
                  borderRadius: BorderRadius.circular(element.borderRadius),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _renderShapeElement(ShapeElement element) {
    return Container(
      width: element.size.width,
      height: element.size.height,
      decoration: element.isSelected
          ? BoxDecoration(
              border: Border.all(color: Colors.blue, width: 2),
            )
          : null,
      child: CustomPaint(
        painter: ShapePainter(element),
        size: element.size,
      ),
    );
  }

  Widget _renderLineElement(LineElement element) {
    return Container(
      width: element.size.width,
      height: element.size.height,
      decoration: element.isSelected
          ? BoxDecoration(
              border: Border.all(color: Colors.blue, width: 2),
            )
          : null,
      child: CustomPaint(
        painter: LinePainter(element),
        size: element.size,
      ),
    );
  }

  Widget _renderBackgroundElement(BackgroundElement element) {
    return Container(
      width: element.size.width,
      height: element.size.height,
      decoration: BoxDecoration(
        color: element.color,
      ),
      child: element.imagePath != null || element.imageUrl != null
          ? _getBackgroundImage(element)
          : null,
    );
  }

  Widget? _getBackgroundImage(BackgroundElement element) {
    if (element.imageUrl != null && element.imageUrl!.startsWith('http')) {
      return Image.network(
        element.imageUrl!,
        width: element.size.width,
        height: element.size.height,
        fit: element.fit,
        errorBuilder: (context, error, stackTrace) => Container(
          width: element.size.width,
          height: element.size.height,
          color: Colors.grey.shade200,
          child: const Icon(
            Icons.broken_image,
            color: Colors.grey,
          ),
        ),
      );
    } else if (element.imagePath != null) {
      final file = File(element.imagePath!);
      if (file.existsSync()) {
        return Image.file(
          file,
          width: element.size.width,
          height: element.size.height,
          fit: element.fit,
          errorBuilder: (context, error, stackTrace) => Container(
            width: element.size.width,
            height: element.size.height,
            color: Colors.grey.shade200,
            child: const Icon(
              Icons.broken_image,
              color: Colors.grey,
            ),
          ),
        );
      }
    }
    return null;
  }
}

/// Custom painter for shape elements
class ShapePainter extends CustomPainter {
  final ShapeElement element;

  ShapePainter(this.element);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = element.fillColor
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = element.strokeColor ?? Colors.transparent
      ..strokeWidth = element.strokeWidth
      ..style = PaintingStyle.stroke;

    switch (element.shapeType) {
      case ShapeType.rectangle:
        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(element.borderRadius),
        );
        canvas.drawRRect(rect, paint);
        if (element.strokeWidth > 0) {
          canvas.drawRRect(rect, strokePaint);
        }
        break;

      case ShapeType.circle:
        final center = Offset(size.width / 2, size.height / 2);
        final radius = size.width / 2;
        canvas.drawCircle(center, radius, paint);
        if (element.strokeWidth > 0) {
          canvas.drawCircle(center, radius, strokePaint);
        }
        break;

      case ShapeType.triangle:
        final path = Path();
        path.moveTo(size.width / 2, 0);
        path.lineTo(size.width, size.height);
        path.lineTo(0, size.height);
        path.close();
        canvas.drawPath(path, paint);
        if (element.strokeWidth > 0) {
          canvas.drawPath(path, strokePaint);
        }
        break;

      case ShapeType.star:
        final path = _createStarPath(size);
        canvas.drawPath(path, paint);
        if (element.strokeWidth > 0) {
          canvas.drawPath(path, strokePaint);
        }
        break;

      case ShapeType.polygon:
        final path = _createPolygonPath(size, 6); // Hexagon by default
        canvas.drawPath(path, paint);
        if (element.strokeWidth > 0) {
          canvas.drawPath(path, strokePaint);
        }
        break;
    }
  }

  Path _createStarPath(Size size) {
    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2;
    final innerRadius = outerRadius * 0.5;
    final numPoints = 5;

    for (int i = 0; i < numPoints * 2; i++) {
      final angle = (i * 3.14159) / numPoints;
      final radius = i.isEven ? outerRadius : innerRadius;
      final x = center.dx + radius * math.cos(angle - 3.14159 / 2);
      final y = center.dy + radius * math.sin(angle - 3.14159 / 2);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  Path _createPolygonPath(Size size, int sides) {
    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    for (int i = 0; i < sides; i++) {
      final angle = (i * 2 * 3.14159) / sides;
      final x = center.dx + radius * math.cos(angle - 3.14159 / 2);
      final y = center.dy + radius * math.sin(angle - 3.14159 / 2);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

/// Custom painter for line elements
class LinePainter extends CustomPainter {
  final LineElement element;

  LinePainter(this.element);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = element.color
      ..strokeWidth = element.strokeWidth
      ..strokeCap = element.strokeCap
      ..style = PaintingStyle.stroke;

    // Convert absolute positions to relative positions within the element bounds
    final start = Offset(
      element.startPoint.dx - element.position.dx,
      element.startPoint.dy - element.position.dy,
    );
    final end = Offset(
      element.endPoint.dx - element.position.dx,
      element.endPoint.dy - element.position.dy,
    );

    canvas.drawLine(start, end, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
