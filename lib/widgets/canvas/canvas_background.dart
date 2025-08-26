import 'package:flutter/material.dart';
import 'dart:io';

/// Widget that renders the canvas background with optional grid and background image
class CanvasBackground extends StatelessWidget {
  final Size size;
  final Color backgroundColor;
  final String? backgroundImagePath;
  final String? backgroundImageUrl;
  final bool showGrid;
  final double gridSize;

  const CanvasBackground({
    super.key,
    required this.size,
    required this.backgroundColor,
    this.backgroundImagePath,
    this.backgroundImageUrl,
    this.showGrid = false,
    this.gridSize = 10.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        color: backgroundColor,
      ),
      child: Stack(
        children: [
          // Background image (if exists)
          if (backgroundImagePath != null || backgroundImageUrl != null)
            _buildBackgroundImage(),
          
          // Grid overlay (if enabled)
          if (showGrid)
            CustomPaint(
              painter: GridPainter(
                gridSize: gridSize,
                canvasSize: size,
              ),
              size: size,
            ),
        ],
      ),
    );
  }

  Widget _buildBackgroundImage() {
    Widget imageWidget;

    if (backgroundImageUrl != null && backgroundImageUrl!.startsWith('http')) {
      // Network image
      imageWidget = Image.network(
        backgroundImageUrl!,
        width: size.width,
        height: size.height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: size.width,
            height: size.height,
            color: Colors.grey.shade100,
            child: const Center(
              child: Icon(
                Icons.broken_image,
                color: Colors.grey,
                size: 50,
              ),
            ),
          );
        },
      );
    } else if (backgroundImagePath != null) {
      // Local file image
      final file = File(backgroundImagePath!);
      if (file.existsSync()) {
        imageWidget = Image.file(
          file,
          width: size.width,
          height: size.height,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: size.width,
              height: size.height,
              color: Colors.grey.shade100,
              child: const Center(
                child: Icon(
                  Icons.broken_image,
                  color: Colors.grey,
                  size: 50,
                ),
              ),
            );
          },
        );
      } else {
        // File doesn't exist
        imageWidget = Container(
          width: size.width,
          height: size.height,
          color: Colors.grey.shade100,
          child: const Center(
            child: Icon(
              Icons.image_not_supported,
              color: Colors.grey,
              size: 50,
            ),
          ),
        );
      }
    } else {
      // No image
      imageWidget = const SizedBox.shrink();
    }

    return Positioned.fill(
      child: ClipRect(
        child: imageWidget,
      ),
    );
  }
}

/// Custom painter for grid overlay
class GridPainter extends CustomPainter {
  final double gridSize;
  final Size canvasSize;

  GridPainter({
    required this.gridSize,
    required this.canvasSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..strokeWidth = 0.5;

    // Draw vertical lines
    for (double x = 0; x <= canvasSize.width; x += gridSize) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, canvasSize.height),
        paint,
      );
    }

    // Draw horizontal lines
    for (double y = 0; y <= canvasSize.height; y += gridSize) {
      canvas.drawLine(
        Offset(0, y),
        Offset(canvasSize.width, y),
        paint,
      );
    }

    // Draw origin indicator
    final originPaint = Paint()
      ..color = Colors.blue.withOpacity(0.5)
      ..strokeWidth = 2.0;

    // Draw small cross at origin
    canvas.drawLine(
      const Offset(-5, 0),
      const Offset(5, 0),
      originPaint,
    );
    canvas.drawLine(
      const Offset(0, -5),
      const Offset(0, 5),
      originPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is GridPainter) {
      return gridSize != oldDelegate.gridSize ||
          canvasSize != oldDelegate.canvasSize;
    }
    return true;
  }
}
