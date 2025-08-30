import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Widget that displays the current side (Front/Back) with transition animation
class SideIndicator extends StatefulWidget {
  final bool isFrontSide;
  final VoidCallback onToggleSide;

  const SideIndicator({
    super.key,
    required this.isFrontSide,
    required this.onToggleSide,
  });

  @override
  State<SideIndicator> createState() => _SideIndicatorState();
}

class _SideIndicatorState extends State<SideIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _flipAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _flipAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _colorAnimation = ColorTween(
      begin: Colors.blue,
      end: Colors.orange,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(SideIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isFrontSide != widget.isFrontSide) {
      if (widget.isFrontSide) {
        _animationController.reverse();
      } else {
        _animationController.forward();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onToggleSide();
        HapticFeedback.mediumImpact();
      },
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // perspective
              ..rotateY(_flipAnimation.value * 3.14159),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _colorAnimation.value,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: (_colorAnimation.value ?? Colors.blue).withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.isFrontSide ? Icons.credit_card : Icons.flip,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.isFrontSide ? 'Front Side' : 'Back Side',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.touch_app,
                    color: Colors.white,
                    size: 16,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// A floating action button for easy side switching
class SideToggleFAB extends StatelessWidget {
  final bool isFrontSide;
  final VoidCallback onToggle;

  const SideToggleFAB({
    super.key,
    required this.isFrontSide,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        onToggle();
        HapticFeedback.mediumImpact();
      },
      backgroundColor: isFrontSide ? Colors.blue : Colors.orange,
      icon: Icon(
        isFrontSide ? Icons.flip : Icons.credit_card,
        color: Colors.white,
      ),
      label: Text(
        'Switch to ${isFrontSide ? 'Back' : 'Front'}',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      heroTag: "sideToggle", // Unique hero tag
    );
  }
}

/// Side indicator for the top toolbar
class CompactSideIndicator extends StatelessWidget {
  final bool isFrontSide;
  final VoidCallback onToggle;

  const CompactSideIndicator({
    super.key,
    required this.isFrontSide,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey.shade100,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSideButton(
            label: 'Front',
            icon: Icons.credit_card,
            isSelected: isFrontSide,
            onPressed: () {
              if (!isFrontSide) onToggle();
            },
          ),
          _buildSideButton(
            label: 'Back',
            icon: Icons.flip,
            isSelected: !isFrontSide,
            onPressed: () {
              if (isFrontSide) onToggle();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSideButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: () {
        onPressed();
        HapticFeedback.lightImpact();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isSelected ? Colors.blue : Colors.transparent,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : Colors.grey.shade600,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
