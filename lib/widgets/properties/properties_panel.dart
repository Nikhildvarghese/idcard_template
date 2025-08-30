import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../models/canvas_element.dart';
import '../../providers/canvas_provider.dart';

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
        color: Colors.white,
        border: Border(left: BorderSide(color: Colors.grey.shade300)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(-2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Properties header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                const Icon(Icons.tune, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Properties',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (selectedElement != null)
                  Text(
                    _getElementTypeName(selectedElement.type),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
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
    );
  }

  Widget _buildElementProperties(
    BuildContext context,
    WidgetRef ref,
    CanvasElement element,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Common properties for all elements
        _buildCommonProperties(context, ref, element),

        const SizedBox(height: 16),

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
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // Canvas size
        _buildSectionTitle('Canvas Size'),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: canvasState.canvasSize.width.toString(),
                decoration: const InputDecoration(
                  labelText: 'Width',
                  border: OutlineInputBorder(),
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
                decoration: const InputDecoration(
                  labelText: 'Height',
                  border: OutlineInputBorder(),
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

        const SizedBox(height: 16),

        // Background color
        _buildSectionTitle('Background'),
        _buildColorPicker(
          context,
          'Background Color',
          canvasState.backgroundColor,
          (color) {
            final canvasNotifier = ref.read(canvasProvider.notifier);
            canvasNotifier.setBackgroundColor(color);
          },
        ),

        const SizedBox(height: 16),

        // Grid settings
        _buildSectionTitle('Grid'),
        CheckboxListTile(
          title: const Text('Show Grid'),
          value: canvasState.isGridVisible,
          onChanged: (value) {
            final canvasNotifier = ref.read(canvasProvider.notifier);
            canvasNotifier.toggleGrid();
          },
        ),
        CheckboxListTile(
          title: const Text('Snap to Grid'),
          value: canvasState.isSnapToGrid,
          onChanged: (value) {
            final canvasNotifier = ref.read(canvasProvider.notifier);
            canvasNotifier.toggleSnapToGrid();
          },
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

        // Position
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: element.position.dx.toStringAsFixed(0),
                decoration: const InputDecoration(
                  labelText: 'X',
                  border: OutlineInputBorder(),
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
                decoration: const InputDecoration(
                  labelText: 'Y',
                  border: OutlineInputBorder(),
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

        const SizedBox(height: 8),

        // Size
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: element.size.width.toStringAsFixed(0),
                decoration: const InputDecoration(
                  labelText: 'Width',
                  border: OutlineInputBorder(),
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
                decoration: const InputDecoration(
                  labelText: 'Height',
                  border: OutlineInputBorder(),
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

        const SizedBox(height: 12),

        // Rotation
        Text(
          'Rotation: ${(element.rotation * 180 / 3.14159).toStringAsFixed(0)}°',
        ),
        Slider(
          value: element.rotation,
          min: -3.14159,
          max: 3.14159,
          onChanged: (value) {
            _updateElement(ref, element.copyWith(rotation: value));
          },
        ),

        const SizedBox(height: 12),

        // Opacity
        Text('Opacity: ${(element.opacity * 100).toStringAsFixed(0)}%'),
        Slider(
          value: element.opacity,
          min: 0.0,
          max: 1.0,
          onChanged: (value) {
            _updateElement(ref, element.copyWith(opacity: value));
          },
        ),

        const SizedBox(height: 12),

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
                label: const Text('Front'),
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
                label: const Text('Back'),
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

        // Text content
        TextFormField(
          initialValue: element.text,
          decoration: const InputDecoration(
            labelText: 'Text',
            border: OutlineInputBorder(),
          ),
          maxLines: null,
          onFieldSubmitted: (value) {
            _updateElement(ref, element.copyWith(text: value));
          },
        ),

        const SizedBox(height: 12),

        // Font size
        Text('Font Size: ${element.fontSize.toStringAsFixed(0)}'),
        Slider(
          value: element.fontSize,
          min: 8,
          max: 72,
          onChanged: (value) {
            _updateElement(ref, element.copyWith(fontSize: value));
          },
        ),

        const SizedBox(height: 12),

        // Font weight
        DropdownButtonFormField<FontWeight>(
          value: element.fontWeight,
          decoration: const InputDecoration(
            labelText: 'Font Weight',
            border: OutlineInputBorder(),
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

        const SizedBox(height: 12),
        // Font family
        DropdownButtonFormField<String>(
          value: element.fontFamily,
          decoration: const InputDecoration(
            labelText: 'Font Family',
            border: OutlineInputBorder(),
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

        const SizedBox(height: 12),

        // Style toggles
        Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.format_bold,
                color: element.fontWeight == FontWeight.bold
                    ? Colors.blue
                    : null,
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
                    ? Colors.blue
                    : null,
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
                    ? Colors.blue
                    : null,
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

        const SizedBox(height: 12),

        // Text alignment
        DropdownButtonFormField<TextAlign>(
          value: element.textAlign,
          decoration: const InputDecoration(
            labelText: 'Text Alignment',
            border: OutlineInputBorder(),
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

        const SizedBox(height: 12),

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

        // Fit
        DropdownButtonFormField<BoxFit>(
          value: element.fit,
          decoration: const InputDecoration(
            labelText: 'Image Fit',
            border: OutlineInputBorder(),
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

        const SizedBox(height: 12),

        // Border radius
        Text('Border Radius: ${element.borderRadius.toStringAsFixed(0)}'),
        Slider(
          value: element.borderRadius,
          min: 0,
          max: 50,
          onChanged: (value) {
            _updateElement(ref, element.copyWith(borderRadius: value));
          },
        ),

        const SizedBox(height: 12),

        // Border width
        Text('Border Width: ${element.borderWidth.toStringAsFixed(0)}'),
        Slider(
          value: element.borderWidth,
          min: 0,
          max: 10,
          onChanged: (value) {
            _updateElement(ref, element.copyWith(borderWidth: value));
          },
        ),

        if (element.borderWidth > 0) ...[
          const SizedBox(height: 12),
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

        // Fill color
        _buildColorPicker(
          context,
          'Fill Color',
          element.fillColor,
          (color) => _updateElement(ref, element.copyWith(fillColor: color)),
        ),

        const SizedBox(height: 12),

        // Stroke width
        Text('Stroke Width: ${element.strokeWidth.toStringAsFixed(0)}'),
        Slider(
          value: element.strokeWidth,
          min: 0,
          max: 10,
          onChanged: (value) {
            _updateElement(ref, element.copyWith(strokeWidth: value));
          },
        ),

        if (element.strokeWidth > 0) ...[
          const SizedBox(height: 12),
          _buildColorPicker(
            context,
            'Stroke Color',
            element.strokeColor ?? Colors.black,
            (color) =>
                _updateElement(ref, element.copyWith(strokeColor: color)),
          ),
        ],

        if (element.shapeType == ShapeType.rectangle) ...[
          const SizedBox(height: 12),
          Text('Corner Radius: ${element.borderRadius.toStringAsFixed(0)}'),
          Slider(
            value: element.borderRadius,
            min: 0,
            max: 50,
            onChanged: (value) {
              _updateElement(ref, element.copyWith(borderRadius: value));
            },
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

        // Line color
        _buildColorPicker(
          context,
          'Line Color',
          element.color,
          (color) => _updateElement(ref, element.copyWith(color: color)),
        ),

        const SizedBox(height: 12),

        // Stroke width
        Text('Line Width: ${element.strokeWidth.toStringAsFixed(0)}'),
        Slider(
          value: element.strokeWidth,
          min: 0.5,
          max: 20,
          onChanged: (value) {
            _updateElement(ref, element.copyWith(strokeWidth: value));
          },
        ),

        const SizedBox(height: 12),

        // Stroke cap
        DropdownButtonFormField<StrokeCap>(
          value: element.strokeCap,
          decoration: const InputDecoration(
            labelText: 'Line Cap',
            border: OutlineInputBorder(),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildColorPicker(
    BuildContext context,
    String label,
    Color currentColor,
    Function(Color) onColorChanged,
  ) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        GestureDetector(
          onTap: () =>
              _showColorPickerDialog(context, currentColor, onColorChanged),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: currentColor,
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
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
        return AlertDialog(
          title: const Text('Pick a Color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: currentColor,
              onColorChanged: onColorChanged,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Done'),
            ),
          ],
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
}
