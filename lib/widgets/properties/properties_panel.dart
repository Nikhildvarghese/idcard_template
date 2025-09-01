import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../models/canvas_element.dart';
import '../../providers/canvas_provider.dart';
import 'dart:ui';

/// Properties panel widget similar to Canva's right sidebar
class PropertiesPanel extends ConsumerWidget {
  const PropertiesPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedElement = ref.watch(selectedElementProvider);
    final canvasState = ref.watch(canvasProvider);

    return Container(
      width: 320,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF5E72E4).withOpacity(0.25),
            const Color(0xFF8FA2F8).withOpacity(0.15),
          ],
        ),
        border: Border(left: BorderSide(color: Colors.grey.shade300)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(-4, 0),
          ),
        ],
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            color: Colors.white.withOpacity(0.1),
            child: SafeArea(
              child: Column(
                children: [
                  // Sticky properties header
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade200),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.tune,
                          size: 20,
                          color: Color(0xFF444444),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Properties',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF333333),
                          ),
                        ),
                        const Spacer(),
                        if (selectedElement != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getElementTypeColor(selectedElement.type),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _getElementTypeName(selectedElement.type),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Properties content
                  Expanded(
                    child: selectedElement != null
                        ? _buildElementProperties(context, ref, selectedElement)
                        : _buildCanvasProperties(context, ref, canvasState),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildElementProperties(
    BuildContext context,
    WidgetRef ref,
    CanvasElement element,
  ) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Common properties for all elements
              _buildCommonProperties(context, ref, element),

              const SizedBox(height: 20),

              // Element-specific properties
              if (element.type == ElementType.text)
                _buildTextProperties(context, ref, element as TextElement),
              if (element.type == ElementType.image)
                _buildImageProperties(context, ref, element as ImageElement),
              if (element.type == ElementType.shape)
                _buildShapeProperties(context, ref, element as ShapeElement),
              if (element.type == ElementType.line)
                _buildLineProperties(context, ref, element as LineElement),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCanvasProperties(
    BuildContext context,
    WidgetRef ref,
    canvasState,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Canvas Settings',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 20),

        // Canvas size
        _buildSectionTitle('Canvas Size'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: canvasState.canvasSize.width.toString(),
                decoration: InputDecoration(
                  labelText: 'Width',
                  labelStyle: const TextStyle(fontSize: 13),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.6),
                ),
                onFieldSubmitted: (value) {
                  final width =
                      double.tryParse(value) ?? canvasState.canvasSize.width;
                  final canvasNotifier = ref.read(canvasProvider.notifier);
                  canvasNotifier.setCanvasSize(
                    Size(width, canvasState.canvasSize.height),
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                initialValue: canvasState.canvasSize.height.toString(),
                decoration: InputDecoration(
                  labelText: 'Height',
                  labelStyle: const TextStyle(fontSize: 13),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.6),
                ),
                onFieldSubmitted: (value) {
                  final height =
                      double.tryParse(value) ?? canvasState.canvasSize.height;
                  final canvasNotifier = ref.read(canvasProvider.notifier);
                  canvasNotifier.setCanvasSize(
                    Size(canvasState.canvasSize.width, height),
                  );
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Background color
        _buildSectionTitle('Background'),
        const SizedBox(height: 8),
        _buildColorPicker(
          context,
          'Background Color',
          canvasState.backgroundColor,
          (color) {
            final canvasNotifier = ref.read(canvasProvider.notifier);
            canvasNotifier.setBackgroundColor(color);
          },
        ),

        const SizedBox(height: 20),

        // Grid settings
        _buildSectionTitle('Grid'),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.6),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              CheckboxListTile(
                title: const Text('Show Grid', style: TextStyle(fontSize: 14)),
                value: canvasState.isGridVisible,
                onChanged: (value) {
                  final canvasNotifier = ref.read(canvasProvider.notifier);
                  canvasNotifier.toggleGrid();
                },
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                dense: true,
              ),
              Divider(height: 1, color: Colors.grey.shade300),
              CheckboxListTile(
                title: const Text(
                  'Snap to Grid',
                  style: TextStyle(fontSize: 14),
                ),
                value: canvasState.isSnapToGrid,
                onChanged: (value) {
                  final canvasNotifier = ref.read(canvasProvider.notifier);
                  canvasNotifier.toggleSnapToGrid();
                },
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                dense: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCommonProperties(
    BuildContext context,
    WidgetRef ref,
    CanvasElement element,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Position & Size'),
        const SizedBox(height: 12),

        // Position
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: element.position.dx.toStringAsFixed(0),
                decoration: InputDecoration(
                  labelText: 'X',
                  labelStyle: const TextStyle(fontSize: 13),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.6),
                ),
                onFieldSubmitted: (value) {
                  final x = double.tryParse(value) ?? element.position.dx;
                  _updateElement(
                    ref,
                    element.copyWith(position: Offset(x, element.position.dy)),
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                initialValue: element.position.dy.toStringAsFixed(0),
                decoration: InputDecoration(
                  labelText: 'Y',
                  labelStyle: const TextStyle(fontSize: 13),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.6),
                ),
                onFieldSubmitted: (value) {
                  final y = double.tryParse(value) ?? element.position.dy;
                  _updateElement(
                    ref,
                    element.copyWith(position: Offset(element.position.dx, y)),
                  );
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Size
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: element.size.width.toStringAsFixed(0),
                decoration: InputDecoration(
                  labelText: 'Width',
                  labelStyle: const TextStyle(fontSize: 13),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.6),
                ),
                onFieldSubmitted: (value) {
                  final width = double.tryParse(value) ?? element.size.width;
                  _updateElement(
                    ref,
                    element.copyWith(size: Size(width, element.size.height)),
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                initialValue: element.size.height.toStringAsFixed(0),
                decoration: InputDecoration(
                  labelText: 'Height',
                  labelStyle: const TextStyle(fontSize: 13),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.6),
                ),
                onFieldSubmitted: (value) {
                  final height = double.tryParse(value) ?? element.size.height;
                  _updateElement(
                    ref,
                    element.copyWith(size: Size(element.size.width, height)),
                  );
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Rotation
        Text(
          'Rotation: ${(element.rotation * 180 / 3.14159).toStringAsFixed(0)}°',
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.6),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Slider(
            value: element.rotation,
            min: -3.14159,
            max: 3.14159,
            activeColor: const Color(0xFF5E72E4),
            inactiveColor: Colors.grey.shade300,
            onChanged: (value) {
              _updateElement(ref, element.copyWith(rotation: value));
            },
          ),
        ),

        const SizedBox(height: 20),

        // Opacity
        Text(
          'Opacity: ${(element.opacity * 100).toStringAsFixed(0)}%',
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.6),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Slider(
            value: element.opacity,
            min: 0.0,
            max: 1.0,
            activeColor: const Color(0xFF5E72E4),
            inactiveColor: Colors.grey.shade300,
            onChanged: (value) {
              _updateElement(ref, element.copyWith(opacity: value));
            },
          ),
        ),

        const SizedBox(height: 20),

        // Layer controls
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  final canvasNotifier = ref.read(canvasProvider.notifier);
                  canvasNotifier.bringToFront(element.id);
                },
                icon: const Icon(Icons.flip_to_front, size: 16),
                label: const Text('Front', style: TextStyle(fontSize: 13)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5E72E4),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  final canvasNotifier = ref.read(canvasProvider.notifier);
                  canvasNotifier.sendToBack(element.id);
                },
                icon: const Icon(Icons.flip_to_back, size: 16),
                label: const Text('Back', style: TextStyle(fontSize: 13)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5E72E4),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextProperties(
    BuildContext context,
    WidgetRef ref,
    TextElement element,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Text Properties'),
        const SizedBox(height: 12),

        // Text content
        TextFormField(
          initialValue: element.text,
          decoration: InputDecoration(
            labelText: 'Text',
            labelStyle: const TextStyle(fontSize: 13),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            filled: true,
            fillColor: Colors.white.withOpacity(0.6),
          ),
          maxLines: null,
          onFieldSubmitted: (value) {
            _updateElement(ref, element.copyWith(text: value));
          },
        ),

        const SizedBox(height: 20),

        // Font size
        Text(
          'Font Size: ${element.fontSize.toStringAsFixed(0)}',
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.6),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Slider(
            value: element.fontSize,
            min: 8,
            max: 72,
            activeColor: const Color(0xFF5E72E4),
            inactiveColor: Colors.grey.shade300,
            onChanged: (value) {
              _updateElement(ref, element.copyWith(fontSize: value));
            },
          ),
        ),

        const SizedBox(height: 20),

        // Font weight
        DropdownButtonFormField<FontWeight>(
          value: element.fontWeight,
          decoration: InputDecoration(
            labelText: 'Font Weight',
            labelStyle: const TextStyle(fontSize: 13),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            filled: true,
            fillColor: Colors.white.withOpacity(0.6),
          ),
          items: const [
            DropdownMenuItem(value: FontWeight.w300, child: Text('Light')),
            DropdownMenuItem(value: FontWeight.normal, child: Text('Normal')),
            DropdownMenuItem(value: FontWeight.w600, child: Text('Medium')),
            DropdownMenuItem(value: FontWeight.bold, child: Text('Bold')),
          ],
          onChanged: (value) {
            if (value != null) {
              _updateElement(ref, element.copyWith(fontWeight: value));
            }
          },
        ),

        const SizedBox(height: 20),

        // Font family
        DropdownButtonFormField<String>(
          value: element.fontFamily,
          decoration: InputDecoration(
            labelText: 'Font Family',
            labelStyle: const TextStyle(fontSize: 13),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            filled: true,
            fillColor: Colors.white.withOpacity(0.6),
          ),
          items: const [
            DropdownMenuItem(value: 'Roboto', child: Text('Roboto')),
            DropdownMenuItem(value: 'OpenSans', child: Text('Open Sans')),
            DropdownMenuItem(value: 'Lato', child: Text('Lato')),
            DropdownMenuItem(value: 'Montserrat', child: Text('Montserrat')),
          ],
          onChanged: (value) {
            if (value != null) {
              _updateElement(ref, element.copyWith(fontFamily: value));
            }
          },
        ),

        const SizedBox(height: 20),

        // Style toggles
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.6),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Icon(
                  Icons.format_bold,
                  color: element.fontWeight == FontWeight.bold
                      ? const Color(0xFF5E72E4)
                      : Colors.grey.shade700,
                ),
                onPressed: () {
                  _updateElement(
                    ref,
                    element.copyWith(
                      fontWeight: element.fontWeight == FontWeight.bold
                          ? FontWeight.normal
                          : FontWeight.bold,
                    ),
                  );
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.format_italic,
                  color: element.fontStyle == FontStyle.italic
                      ? const Color(0xFF5E72E4)
                      : Colors.grey.shade700,
                ),
                onPressed: () {
                  _updateElement(
                    ref,
                    element.copyWith(
                      fontStyle: element.fontStyle == FontStyle.italic
                          ? FontStyle.normal
                          : FontStyle.italic,
                    ),
                  );
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.format_underline,
                  color: element.textDecoration == TextDecoration.underline
                      ? const Color(0xFF5E72E4)
                      : Colors.grey.shade700,
                ),
                onPressed: () {
                  _updateElement(
                    ref,
                    element.copyWith(
                      textDecoration:
                          element.textDecoration == TextDecoration.underline
                          ? TextDecoration.none
                          : TextDecoration.underline,
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Text alignment
        DropdownButtonFormField<TextAlign>(
          value: element.textAlign,
          decoration: InputDecoration(
            labelText: 'Text Alignment',
            labelStyle: const TextStyle(fontSize: 13),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            filled: true,
            fillColor: Colors.white.withOpacity(0.6),
          ),
          items: const [
            DropdownMenuItem(value: TextAlign.left, child: Text('Left')),
            DropdownMenuItem(value: TextAlign.center, child: Text('Center')),
            DropdownMenuItem(value: TextAlign.right, child: Text('Right')),
            DropdownMenuItem(value: TextAlign.justify, child: Text('Justify')),
          ],
          onChanged: (value) {
            if (value != null) {
              _updateElement(ref, element.copyWith(textAlign: value));
            }
          },
        ),

        const SizedBox(height: 20),

        // Text color
        _buildColorPicker(
          context,
          'Text Color',
          element.color,
          (color) => _updateElement(ref, element.copyWith(color: color)),
        ),
      ],
    );
  }

  Widget _buildImageProperties(
    BuildContext context,
    WidgetRef ref,
    ImageElement element,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Image Properties'),
        const SizedBox(height: 12),

        // Fit
        DropdownButtonFormField<BoxFit>(
          value: element.fit,
          decoration: InputDecoration(
            labelText: 'Image Fit',
            labelStyle: const TextStyle(fontSize: 13),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            filled: true,
            fillColor: Colors.white.withOpacity(0.6),
          ),
          items: const [
            DropdownMenuItem(value: BoxFit.cover, child: Text('Cover')),
            DropdownMenuItem(value: BoxFit.contain, child: Text('Contain')),
            DropdownMenuItem(value: BoxFit.fill, child: Text('Fill')),
            DropdownMenuItem(value: BoxFit.fitWidth, child: Text('Fit Width')),
            DropdownMenuItem(
              value: BoxFit.fitHeight,
              child: Text('Fit Height'),
            ),
          ],
          onChanged: (value) {
            if (value != null) {
              _updateElement(ref, element.copyWith(fit: value));
            }
          },
        ),

        const SizedBox(height: 20),

        // Border radius
        Text(
          'Border Radius: ${element.borderRadius.toStringAsFixed(0)}',
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.6),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Slider(
            value: element.borderRadius,
            min: 0,
            max: 50,
            activeColor: const Color(0xFF5E72E4),
            inactiveColor: Colors.grey.shade300,
            onChanged: (value) {
              _updateElement(ref, element.copyWith(borderRadius: value));
            },
          ),
        ),

        const SizedBox(height: 20),

        // Border width
        Text(
          'Border Width: ${element.borderWidth.toStringAsFixed(0)}',
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.6),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Slider(
            value: element.borderWidth,
            min: 0,
            max: 10,
            activeColor: const Color(0xFF5E72E4),
            inactiveColor: Colors.grey.shade300,
            onChanged: (value) {
              _updateElement(ref, element.copyWith(borderWidth: value));
            },
          ),
        ),

        if (element.borderWidth > 0) ...[
          const SizedBox(height: 20),
          _buildColorPicker(
            context,
            'Border Color',
            element.borderColor ?? Colors.black,
            (color) =>
                _updateElement(ref, element.copyWith(borderColor: color)),
          ),
        ],
      ],
    );
  }

  Widget _buildShapeProperties(
    BuildContext context,
    WidgetRef ref,
    ShapeElement element,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Shape Properties'),
        const SizedBox(height: 12),

        // Fill color
        _buildColorPicker(
          context,
          'Fill Color',
          element.fillColor,
          (color) => _updateElement(ref, element.copyWith(fillColor: color)),
        ),

        const SizedBox(height: 20),

        // Stroke width
        Text(
          'Stroke Width: ${element.strokeWidth.toStringAsFixed(0)}',
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.6),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Slider(
            value: element.strokeWidth,
            min: 0,
            max: 10,
            activeColor: const Color(0xFF5E72E4),
            inactiveColor: Colors.grey.shade300,
            onChanged: (value) {
              _updateElement(ref, element.copyWith(strokeWidth: value));
            },
          ),
        ),

        if (element.strokeWidth > 0) ...[
          const SizedBox(height: 20),
          _buildColorPicker(
            context,
            'Stroke Color',
            element.strokeColor ?? Colors.black,
            (color) =>
                _updateElement(ref, element.copyWith(strokeColor: color)),
          ),
        ],

        if (element.shapeType == ShapeType.rectangle) ...[
          const SizedBox(height: 20),
          Text(
            'Corner Radius: ${element.borderRadius.toStringAsFixed(0)}',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Slider(
              value: element.borderRadius,
              min: 0,
              max: 50,
              activeColor: const Color(0xFF5E72E4),
              inactiveColor: Colors.grey.shade300,
              onChanged: (value) {
                _updateElement(ref, element.copyWith(borderRadius: value));
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLineProperties(
    BuildContext context,
    WidgetRef ref,
    LineElement element,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Line Properties'),
        const SizedBox(height: 12),

        // Line color
        _buildColorPicker(
          context,
          'Line Color',
          element.color,
          (color) => _updateElement(ref, element.copyWith(color: color)),
        ),

        const SizedBox(height: 20),

        // Stroke width
        Text(
          'Line Width: ${element.strokeWidth.toStringAsFixed(0)}',
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.6),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Slider(
            value: element.strokeWidth,
            min: 0.5,
            max: 20,
            activeColor: const Color(0xFF5E72E4),
            inactiveColor: Colors.grey.shade300,
            onChanged: (value) {
              _updateElement(ref, element.copyWith(strokeWidth: value));
            },
          ),
        ),

        const SizedBox(height: 20),

        // Stroke cap
        DropdownButtonFormField<StrokeCap>(
          value: element.strokeCap,
          decoration: InputDecoration(
            labelText: 'Line Cap',
            labelStyle: const TextStyle(fontSize: 13),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            filled: true,
            fillColor: Colors.white.withOpacity(0.6),
          ),
          items: const [
            DropdownMenuItem(value: StrokeCap.round, child: Text('Round')),
            DropdownMenuItem(value: StrokeCap.square, child: Text('Square')),
            DropdownMenuItem(value: StrokeCap.butt, child: Text('Butt')),
          ],
          onChanged: (value) {
            if (value != null) {
              _updateElement(ref, element.copyWith(strokeCap: value));
            }
          },
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF444444),
      ),
    );
  }

  Widget _buildColorPicker(
    BuildContext context,
    String label,
    Color currentColor,
    Function(Color) onColorChanged,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          const Spacer(),
          GestureDetector(
            onTap: () =>
                _showColorPickerDialog(context, currentColor, onColorChanged),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: currentColor,
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showColorPickerDialog(
    BuildContext context,
    Color currentColor,
    Function(Color) onColorChanged,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white.withOpacity(0.9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Pick a Color',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  ColorPicker(
                    pickerColor: currentColor,
                    onColorChanged: onColorChanged,
                    displayThumbColor: true,
                    enableAlpha: false,
                    portraitOnly: true,
                    pickerAreaHeightPercent: 0.6,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5E72E4),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Done'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _updateElement(WidgetRef ref, CanvasElement updatedElement) {
    final canvasNotifier = ref.read(canvasProvider.notifier);
    canvasNotifier.updateElement(updatedElement);
  }

  String _getElementTypeName(ElementType type) {
    switch (type) {
      case ElementType.text:
        return 'Text';
      case ElementType.image:
        return 'Image';
      case ElementType.shape:
        return 'Shape';
      case ElementType.line:
        return 'Line';
      case ElementType.background:
        return 'Background';
    }
  }

  Color _getElementTypeColor(ElementType type) {
    switch (type) {
      case ElementType.text:
        return const Color(0xFF5E72E4);
      case ElementType.image:
        return const Color(0xFFFB6340);
      case ElementType.shape:
        return const Color(0xFF2DCE89);
      case ElementType.line:
        return const Color(0xFFF5365C);
      case ElementType.background:
        return const Color(0xFF11CDEF);
    }
  }
}
