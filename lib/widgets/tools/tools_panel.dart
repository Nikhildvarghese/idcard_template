import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/canvas_element.dart';
import '../../providers/canvas_provider.dart';

/// Main tools panel widget similar to Canva's left sidebar
class ToolsPanel extends ConsumerWidget {
  const ToolsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF5E72E4).withOpacity(0.25),
            const Color(0xFF8FA2F8).withOpacity(0.15),
          ],
        ),
        border: Border(right: BorderSide(color: Colors.grey.shade300)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(-4, 0),
          ),
        ],
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            color: Colors.white.withOpacity(0.1),
            child: SafeArea(
              // ensures header isn't stuck at the very top
              child: Column(
                children: [
                  // Tools header
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey.shade300.withOpacity(0.5),
                        ),
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
                      children: const [
                        Icon(
                          Icons.design_services,
                          color: Colors.black87,
                          size: 22,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Design Tools',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Tools list
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _buildToolCategory('Text', Icons.text_fields, [
                          _ToolItem(
                            'Add Text',
                            Icons.title,
                            () => _addText(ref),
                          ),
                          _ToolItem(
                            'Add Heading',
                            Icons.text_increase,
                            () => _addHeading(ref),
                          ),
                        ]),

                        const SizedBox(height: 24),

                        _buildToolCategory('Elements', Icons.category, [
                          _ToolItem(
                            'Rectangle',
                            Icons.crop_square,
                            () => _addRectangle(ref),
                          ),
                          _ToolItem(
                            'Circle',
                            Icons.circle_outlined,
                            () => _addCircle(ref),
                          ),
                          _ToolItem(
                            'Triangle',
                            Icons.change_history,
                            () => _addTriangle(ref),
                          ),
                          _ToolItem(
                            'Star',
                            Icons.star_outline,
                            () => _addStar(ref),
                          ),
                          _ToolItem(
                            'Line',
                            Icons.horizontal_rule,
                            () => _addLine(ref),
                          ),
                          _ToolItem(
                            'Diamond',
                            Icons.diamond_outlined,
                            () => _addDiamond(ref),
                          ),
                          _ToolItem(
                            'Hexagon',
                            Icons.hexagon_outlined,
                            () => _addHexagon(ref),
                          ),
                          _ToolItem(
                            'Heart',
                            Icons.favorite_border,
                            () => _addHeart(ref),
                          ),
                          _ToolItem(
                            'Pentagon',
                            Icons.pentagon_outlined,
                            () => _addPentagon(ref),
                          ),
                          _ToolItem(
                            'Octagon',
                            Icons.on_device_training_outlined,
                            () => _addOctagon(ref),
                          ),
                          _ToolItem(
                            'Parallelogram',
                            Icons.square_outlined,
                            () => _addParallelogram(ref),
                          ),
                          _ToolItem(
                            'Trapezoid',
                            Icons.crop_landscape_outlined,
                            () => _addTrapezoid(ref),
                          ),
                          _ToolItem(
                            'Arrow',
                            Icons.arrow_right_alt_outlined,
                            () => _addArrow(ref),
                          ),
                          _ToolItem('Cross', Icons.close, () => _addCross(ref)),
                          _ToolItem(
                            'Moon',
                            Icons.dark_mode_outlined,
                            () => _addMoon(ref),
                          ),
                          _ToolItem(
                            'Cloud',
                            Icons.cloud_outlined,
                            () => _addCloud(ref),
                          ),
                        ]),

                        const SizedBox(height: 24),

                        _buildToolCategory('Media', Icons.image, [
                          _ToolItem(
                            'Upload Image',
                            Icons.upload,
                            () => _uploadImage(ref),
                          ),
                          _ToolItem(
                            'Stock Photos',
                            Icons.photo_library,
                            () => _showStockPhotos(context),
                          ),
                        ]),

                        const SizedBox(height: 24),

                        _buildToolCategory('Background', Icons.wallpaper, [
                          _ToolItem(
                            'Solid Color',
                            Icons.palette,
                            () => _showColorPicker(context, ref),
                          ),
                          _ToolItem(
                            'Background Image',
                            Icons.image,
                            () => _uploadBackgroundImage(ref),
                          ),
                        ]),

                        const SizedBox(height: 24),

                        _buildToolCategory('Templates', Icons.dashboard, [
                          _ToolItem(
                            'ID Card Templates',
                            Icons.badge,
                            () => _showTemplates(context, ref),
                          ),
                          _ToolItem(
                            'Business Cards',
                            Icons.credit_card,
                            () => _showBusinessCardTemplates(context, ref),
                          ),
                        ]),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToolCategory(
    String title,
    IconData icon,
    List<_ToolItem> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Colors.black87.withOpacity(0.8)),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87.withOpacity(0.85),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildToolButton(item),
          ),
        ),
      ],
    );
  }

  Widget _buildToolButton(_ToolItem item) {
    return SizedBox(
      width: double.infinity,
      child: TextButton.icon(
        onPressed: item.onTap,
        icon: Icon(item.icon, size: 20, color: Colors.black87),
        label: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            item.title,
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        style: TextButton.styleFrom(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: Colors.white.withOpacity(0.4),
        ),
      ),
    );
  }

  // Tool actions (unchanged)
  void _addText(WidgetRef ref) {
    final canvasNotifier = ref.read(canvasProvider.notifier);
    canvasNotifier.addTextElement(
      text: 'Your text here',
      position: const Offset(100, 100),
      fontSize: 16,
    );
  }

  void _addHeading(WidgetRef ref) {
    final canvasNotifier = ref.read(canvasProvider.notifier);
    canvasNotifier.addTextElement(
      text: 'Heading',
      position: const Offset(100, 50),
      fontSize: 24,
      fontWeight: FontWeight.bold,
    );
  }

  void _addRectangle(WidgetRef ref) {
    final canvasNotifier = ref.read(canvasProvider.notifier);
    canvasNotifier.addShapeElement(
      shapeType: ShapeType.rectangle,
      position: const Offset(150, 150),
      size: const Size(100, 80),
      fillColor: Colors.blue,
    );
  }

  void _addCircle(WidgetRef ref) {
    final canvasNotifier = ref.read(canvasProvider.notifier);
    canvasNotifier.addShapeElement(
      shapeType: ShapeType.circle,
      position: const Offset(150, 150),
      size: const Size(80, 80),
      fillColor: Colors.green,
    );
  }

  void _addTriangle(WidgetRef ref) {
    final canvasNotifier = ref.read(canvasProvider.notifier);
    canvasNotifier.addShapeElement(
      shapeType: ShapeType.triangle,
      position: const Offset(150, 150),
      size: const Size(80, 80),
      fillColor: Colors.orange,
    );
  }

  void _addStar(WidgetRef ref) {
    final canvasNotifier = ref.read(canvasProvider.notifier);
    canvasNotifier.addShapeElement(
      shapeType: ShapeType.star,
      position: const Offset(150, 150),
      size: const Size(80, 80),
      fillColor: Colors.yellow,
    );
  }

  void _addLine(WidgetRef ref) {
    final canvasNotifier = ref.read(canvasProvider.notifier);
    canvasNotifier.addLineElement(
      startPoint: const Offset(100, 200),
      endPoint: const Offset(200, 200),
      color: Colors.black,
      strokeWidth: 2,
    );
  }

  void _addDiamond(WidgetRef ref) {
    final canvasNotifier = ref.read(canvasProvider.notifier);
    canvasNotifier.addShapeElement(
      shapeType: ShapeType.diamond,
      position: const Offset(150, 150),
      size: const Size(80, 80),
      fillColor: Colors.purple,
    );
  }

  void _addHexagon(WidgetRef ref) {
    final canvasNotifier = ref.read(canvasProvider.notifier);
    canvasNotifier.addShapeElement(
      shapeType: ShapeType.hexagon,
      position: const Offset(150, 150),
      size: const Size(100, 100),
      fillColor: Colors.teal,
    );
  }

  void _addHeart(WidgetRef ref) {
    final canvasNotifier = ref.read(canvasProvider.notifier);
    canvasNotifier.addShapeElement(
      shapeType: ShapeType.heart,
      position: const Offset(150, 150),
      size: const Size(90, 90),
      fillColor: Colors.red,
    );
  }

  void _addPentagon(WidgetRef ref) {
    final canvasNotifier = ref.read(canvasProvider.notifier);
    canvasNotifier.addShapeElement(
      shapeType: ShapeType.pentagon,
      position: const Offset(150, 150),
      size: const Size(100, 100),
      fillColor: Colors.indigo,
    );
  }

  void _addOctagon(WidgetRef ref) {
    final canvasNotifier = ref.read(canvasProvider.notifier);
    canvasNotifier.addShapeElement(
      shapeType: ShapeType.octagon,
      position: const Offset(150, 150),
      size: const Size(100, 100),
      fillColor: Colors.deepOrange,
    );
  }

  void _addParallelogram(WidgetRef ref) {
    final canvasNotifier = ref.read(canvasProvider.notifier);
    canvasNotifier.addShapeElement(
      shapeType: ShapeType.parallelogram,
      position: const Offset(150, 150),
      size: const Size(120, 80),
      fillColor: Colors.cyan,
    );
  }

  void _addTrapezoid(WidgetRef ref) {
    final canvasNotifier = ref.read(canvasProvider.notifier);
    canvasNotifier.addShapeElement(
      shapeType: ShapeType.trapezoid,
      position: const Offset(150, 150),
      size: const Size(120, 80),
      fillColor: Colors.brown,
    );
  }

  void _addArrow(WidgetRef ref) {
    final canvasNotifier = ref.read(canvasProvider.notifier);
    canvasNotifier.addShapeElement(
      shapeType: ShapeType.arrow,
      position: const Offset(150, 150),
      size: const Size(120, 80),
      fillColor: Colors.blueGrey,
    );
  }

  void _addCross(WidgetRef ref) {
    final canvasNotifier = ref.read(canvasProvider.notifier);
    canvasNotifier.addShapeElement(
      shapeType: ShapeType.cross,
      position: const Offset(150, 150),
      size: const Size(100, 100),
      fillColor: Colors.pink,
    );
  }

  void _addMoon(WidgetRef ref) {
    final canvasNotifier = ref.read(canvasProvider.notifier);
    canvasNotifier.addShapeElement(
      shapeType: ShapeType.moon,
      position: const Offset(150, 150),
      size: const Size(100, 100),
      fillColor: Colors.amber,
    );
  }

  void _addCloud(WidgetRef ref) {
    final canvasNotifier = ref.read(canvasProvider.notifier);
    canvasNotifier.addShapeElement(
      shapeType: ShapeType.cloud,
      position: const Offset(150, 150),
      size: const Size(140, 100),
      fillColor: Colors.lightBlue,
    );
  }

  void _uploadImage(WidgetRef ref) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final canvasNotifier = ref.read(canvasProvider.notifier);
      canvasNotifier.addImageElement(
        imagePath: pickedFile.path,
        position: const Offset(100, 100),
        size: const Size(150, 100),
      );
    }
  }

  void _uploadBackgroundImage(WidgetRef ref) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final canvasNotifier = ref.read(canvasProvider.notifier);
      canvasNotifier.setBackgroundImage(imagePath: pickedFile.path);
    }
  }

  void _showColorPicker(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => ColorPickerDialog(
        onColorSelected: (color) {
          final canvasNotifier = ref.read(canvasProvider.notifier);
          canvasNotifier.setBackgroundColor(color);
        },
      ),
    );
  }

  void _showStockPhotos(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const StockPhotosDialog(),
    );
  }

  void _showTemplates(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => TemplatesDialog(
        onTemplateSelected: (template) {
          final canvasNotifier = ref.read(canvasProvider.notifier);
          canvasNotifier.loadCanvasFromJson(template);
        },
      ),
    );
  }

  void _showBusinessCardTemplates(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => BusinessCardTemplatesDialog(
        onTemplateSelected: (template) {
          final canvasNotifier = ref.read(canvasProvider.notifier);
          canvasNotifier.loadCanvasFromJson(template);
        },
      ),
    );
  }
}

class _ToolItem {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  _ToolItem(this.title, this.icon, this.onTap);
}

/// Color picker dialog
class ColorPickerDialog extends StatelessWidget {
  final Function(Color) onColorSelected;
  const ColorPickerDialog({super.key, required this.onColorSelected});

  @override
  Widget build(BuildContext context) {
    final colors = [
      Colors.white,
      Colors.black,
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.yellow,
      Colors.orange,
      Colors.purple,
      Colors.pink,
      Colors.cyan,
      Colors.brown,
      Colors.grey,
    ];

    return AlertDialog(
      title: const Text('Select Background Color'),
      content: SizedBox(
        width: 300,
        child: GridView.builder(
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: colors.length,
          itemBuilder: (context, index) {
            final color = colors[index];
            return GestureDetector(
              onTap: () {
                onColorSelected(color);
                Navigator.pop(context);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

/// Stock photos dialog
class StockPhotosDialog extends StatelessWidget {
  const StockPhotosDialog({super.key});
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Stock Photos'),
      content: const SizedBox(
        width: 400,
        height: 300,
        child: Center(
          child: Text(
            'Stock photos feature coming soon!\nFor now, use the upload image option.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

/// Templates dialog
class TemplatesDialog extends StatelessWidget {
  final Function(Map<String, dynamic>) onTemplateSelected;
  const TemplatesDialog({super.key, required this.onTemplateSelected});
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('ID Card Templates'),
      content: const SizedBox(
        width: 400,
        height: 300,
        child: Center(
          child: Text(
            'Templates feature coming soon!\nStart with a blank canvas for now.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

/// Business card templates dialog
class BusinessCardTemplatesDialog extends StatelessWidget {
  final Function(Map<String, dynamic>) onTemplateSelected;
  const BusinessCardTemplatesDialog({
    super.key,
    required this.onTemplateSelected,
  });
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Business Card Templates'),
      content: const SizedBox(
        width: 400,
        height: 300,
        child: Center(
          child: Text(
            'Business card templates coming soon!\nUse the standard ID card size for now.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
