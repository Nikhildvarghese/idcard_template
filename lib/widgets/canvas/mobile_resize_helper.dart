import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../../models/canvas_element.dart';

/// Resize mode options
enum ResizeMode { proportional, width, height, custom }

/// Mobile-friendly resize helper widget that provides visual feedback
/// and alternative methods for resizing elements on touch devices
class MobileResizeHelper extends StatefulWidget {
  final CanvasElement element;
  final Function(Size) onResize;
  final VoidCallback? onClose;

  const MobileResizeHelper({
    super.key,
    required this.element,
    required this.onResize,
    this.onClose,
  });

  @override
  State<MobileResizeHelper> createState() => _MobileResizeHelperState();
}

class _MobileResizeHelperState extends State<MobileResizeHelper>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Size _currentSize;
  ResizeMode _currentMode = ResizeMode.proportional;

  @override
  void initState() {
    super.initState();
    _currentSize = widget.element.size;
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Resize Element',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: widget.onClose,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Current size display
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Current Size',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'W: ${_currentSize.width.toStringAsFixed(0)} × H: ${_currentSize.height.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Resize mode selector
                _buildResizeModeSelector(),
                
                const SizedBox(height: 16),
                
                // Quick size buttons
                _buildQuickSizeButtons(),
                
                const SizedBox(height: 16),
                
                // Slider controls based on selected mode
                _buildSliderControls(),
                
                const SizedBox(height: 16),
                
                // Apply button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onResize(_currentSize);
                      HapticFeedback.lightImpact();
                      widget.onClose?.call();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Apply Size',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildResizeModeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Resize Mode',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: ResizeMode.values.map((mode) {
            final isSelected = _currentMode == mode;
            return FilterChip(
              label: Text(_getResizeModeLabel(mode)),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _currentMode = mode;
                  });
                  HapticFeedback.lightImpact();
                }
              },
              selectedColor: Colors.blue.shade100,
              checkmarkColor: Colors.blue.shade700,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildQuickSizeButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildQuickButton(
                label: '50%',
                onPressed: () => _scaleElement(0.5),
                icon: Icons.compress,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildQuickButton(
                label: '150%',
                onPressed: () => _scaleElement(1.5),
                icon: Icons.expand,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildQuickButton(
                label: '200%',
                onPressed: () => _scaleElement(2.0),
                icon: Icons.zoom_out_map,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickButton({
    required String label,
    required VoidCallback onPressed,
    required IconData icon,
  }) {
    return OutlinedButton(
      onPressed: () {
        onPressed();
        HapticFeedback.lightImpact();
      },
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildSliderControls() {
    switch (_currentMode) {
      case ResizeMode.proportional:
        return _buildProportionalSlider();
      case ResizeMode.width:
        return _buildWidthSlider();
      case ResizeMode.height:
        return _buildHeightSlider();
      case ResizeMode.custom:
        return _buildCustomSliders();
    }
  }

  Widget _buildProportionalSlider() {
    final scale = _currentSize.width / widget.element.size.width;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Scale',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Text('0.5x'),
            Expanded(
              child: Slider(
                value: scale.clamp(0.5, 3.0),
                min: 0.5,
                max: 3.0,
                divisions: 25,
                label: '${scale.toStringAsFixed(1)}x',
                onChanged: (value) {
                  _scaleElement(value);
                },
              ),
            ),
            const Text('3.0x'),
          ],
        ),
      ],
    );
  }

  Widget _buildWidthSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Width',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Text('20'),
            Expanded(
              child: Slider(
                value: _currentSize.width.clamp(20, 500),
                min: 20,
                max: 500,
                divisions: 48,
                label: _currentSize.width.toStringAsFixed(0),
                onChanged: (value) {
                  setState(() {
                    _currentSize = Size(value, _currentSize.height);
                  });
                },
              ),
            ),
            const Text('500'),
          ],
        ),
      ],
    );
  }

  Widget _buildHeightSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Height',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Text('20'),
            Expanded(
              child: Slider(
                value: _currentSize.height.clamp(20, 500),
                min: 20,
                max: 500,
                divisions: 48,
                label: _currentSize.height.toStringAsFixed(0),
                onChanged: (value) {
                  setState(() {
                    _currentSize = Size(_currentSize.width, value);
                  });
                },
              ),
            ),
            const Text('500'),
          ],
        ),
      ],
    );
  }

  Widget _buildCustomSliders() {
    return Column(
      children: [
        _buildWidthSlider(),
        const SizedBox(height: 12),
        _buildHeightSlider(),
      ],
    );
  }

  void _scaleElement(double scale) {
    setState(() {
      _currentSize = Size(
        widget.element.size.width * scale,
        widget.element.size.height * scale,
      );
    });
  }

  String _getResizeModeLabel(ResizeMode mode) {
    switch (mode) {
      case ResizeMode.proportional:
        return 'Scale';
      case ResizeMode.width:
        return 'Width';
      case ResizeMode.height:
        return 'Height';
      case ResizeMode.custom:
        return 'Custom';
    }
  }
}

/// Show mobile resize helper dialog
void showMobileResizeHelper({
  required BuildContext context,
  required CanvasElement element,
  required Function(Size) onResize,
}) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      child: MobileResizeHelper(
        element: element,
        onResize: onResize,
        onClose: () => Navigator.of(context).pop(),
      ),
    ),
  );
}
