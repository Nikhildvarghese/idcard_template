import 'dart:ui';
import 'package:flutter/painting.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/canvas_state.dart';
import '../models/canvas_element.dart';

/// Canvas state notifier for managing canvas operations
class CanvasNotifier extends StateNotifier<CanvasState> {
  CanvasNotifier() : super(CanvasState.empty());

  // Maintain separate element lists for front/back without changing the model schema
  List<CanvasElement> _frontElements = [];
  List<CanvasElement> _backElements = [];
  bool _isFrontSide = true; // true = front, false = back

  bool get isFrontSide => _isFrontSide;

  /// Add a new element to the canvas
  void addElement(CanvasElement element) {
    // Ensure side storage is initialized
    _ensureSideStorage();
    state = state.addElement(element);
    _saveToHistory();
  }

  /// Remove element from canvas
  void removeElement(String elementId) {
    state = state.removeElement(elementId);
    _saveToHistory();
  }

  /// Update existing element
  void updateElement(CanvasElement updatedElement) {
    state = state.updateElement(updatedElement);
  }

  /// Select element
  void selectElement(String? elementId) {
    state = state.selectElement(elementId);
  }

  /// Add to multi-selection
  void addToMultiSelection(String elementId) {
    state = state.addToMultiSelection(elementId);
  }

  /// Remove from multi-selection
  void removeFromMultiSelection(String elementId) {
    state = state.removeFromMultiSelection(elementId);
  }

  /// Clear all selections
  void clearSelection() {
    state = state.clearSelection();
  }

  /// Move selected elements
  void moveSelectedElements(Offset delta) {
    state = state.moveSelectedElements(delta);
  }

  /// Resize selected element
  void resizeSelectedElement(Size newSize) {
    state = state.resizeSelectedElement(newSize);
    _saveToHistory();
  }

  /// Rotate selected element
  void rotateSelectedElement(double rotation) {
    state = state.rotateSelectedElement(rotation);
    _saveToHistory();
  }

  /// Bring element to front
  void bringToFront(String elementId) {
    state = state.bringToFront(elementId);
    _saveToHistory();
  }

  /// Send element to back
  void sendToBack(String elementId) {
    state = state.sendToBack(elementId);
    _saveToHistory();
  }

  /// Duplicate selected element
  void duplicateSelectedElement() {
    state = state.duplicateSelectedElement();
    _saveToHistory();
  }

  /// Set zoom level
  void setZoom(double zoom) {
    state = state.setZoom(zoom);
  }

  /// Set pan offset
  void setPan(Offset panOffset) {
    state = state.setPan(panOffset);
  }

  /// Toggle grid visibility
  void toggleGrid() {
    state = state.toggleGrid();
  }

  /// Toggle snap to grid
  void toggleSnapToGrid() {
    state = state.toggleSnapToGrid();
  }

  /// Set canvas size
  void setCanvasSize(Size size) {
    state = state.setCanvasSize(size);
    _saveToHistory();
  }

  /// Set background color
  void setBackgroundColor(Color color) {
    state = state.setBackgroundColor(color);
    _saveToHistory();
  }

  /// Set background image
  void setBackgroundImage({String? imagePath, String? imageUrl}) {
    state = state.setBackgroundImage(imagePath: imagePath, imageUrl: imageUrl);
    _saveToHistory();
  }

  /// Clear background image
  void clearBackgroundImage() {
    state = state.clearBackgroundImage();
    _saveToHistory();
  }

  /// Add text element
  void addTextElement({
    required String text,
    required Offset position,
    Size? size,
    String fontFamily = 'Roboto',
    double fontSize = 16.0,
    Color color = const Color(0xFF000000),
    FontWeight fontWeight = FontWeight.normal,
    TextAlign textAlign = TextAlign.left,
  }) {
    final element = TextElement(
      id: ElementIdGenerator.generate(),
      position: position,
      size: size ?? const Size(200, 50),
      text: text,
      fontFamily: fontFamily,
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
      textAlign: textAlign,
    );
    
    addElement(element);
  }

  /// Add image element
  void addImageElement({
    required String imagePath,
    required Offset position,
    required Size size,
    String? imageUrl,
    BoxFit fit = BoxFit.cover,
  }) {
    final element = ImageElement(
      id: ElementIdGenerator.generate(),
      position: position,
      size: size,
      imagePath: imagePath,
      imageUrl: imageUrl,
      fit: fit,
    );
    
    addElement(element);
  }

  /// Add shape element
  void addShapeElement({
    required ShapeType shapeType,
    required Offset position,
    required Size size,
    Color fillColor = const Color(0xFF000000),
    Color? strokeColor,
    double strokeWidth = 0.0,
  }) {
    final element = ShapeElement(
      id: ElementIdGenerator.generate(),
      position: position,
      size: size,
      shapeType: shapeType,
      fillColor: fillColor,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
    );
    
    addElement(element);
  }

  /// Add line element
  void addLineElement({
    required Offset startPoint,
    required Offset endPoint,
    Color color = const Color(0xFF000000),
    double strokeWidth = 2.0,
    StrokeCap strokeCap = StrokeCap.round,
  }) {
    final element = LineElement(
      id: ElementIdGenerator.generate(),
      startPoint: startPoint,
      endPoint: endPoint,
      color: color,
      strokeWidth: strokeWidth,
      strokeCap: strokeCap,
    );
    
    addElement(element);
  }

  /// Save current state to history for undo/redo
  void _saveToHistory() {
    // Implement undo/redo history management
    // For now, we'll keep it simple and not implement full history
    // In a production app, you'd want to manage a history stack
  }

  /// Undo last action
  void undo() {
    // Implement undo functionality
    // This would restore the previous state from history
  }

  /// Redo last undone action
  void redo() {
    // Implement redo functionality
    // This would restore the next state from history
  }

  /// Clear entire canvas
  void clearCanvas() {
    state = CanvasState.empty().copyWith(
      canvasSize: state.canvasSize,
      zoom: state.zoom,
      panOffset: state.panOffset,
    );
    // Clear side-specific storage as well
    _frontElements = [];
    _backElements = [];
    _isFrontSide = true;
    _saveToHistory();
  }

  /// Load canvas state from JSON
  void loadCanvasFromJson(Map<String, dynamic> json) {
    try {
      state = CanvasState.fromJson(json);
    } catch (e) {
      // Handle error loading canvas
      print('Error loading canvas: $e');
    }
  }

  /// Get canvas state as JSON
  Map<String, dynamic> getCanvasAsJson() {
    return state.toJson();
  }

  /// Get element at point
  CanvasElement? getElementAtPoint(Offset point) {
    return state.getElementAtPoint(point);
  }

  /// Handle tap on canvas with mobile-optimized touch area
  void handleCanvasTap(Offset localPosition) {
    final element = _getElementAtPointWithTouchTolerance(localPosition);
    if (element != null) {
      selectElement(element.id);
      // Add haptic feedback on mobile
      if (_isMobile) {
        HapticFeedback.lightImpact();
      }
    } else {
      clearSelection();
    }
  }

  /// Handle pan start for selected elements
  void handlePanStart(Offset localPosition) {
    final element = getElementAtPoint(localPosition);
    if (element != null && !state.multiSelectedElementIds.contains(element.id)) {
      selectElement(element.id);
    }
  }

  /// Handle pan update for moving elements
  void handlePanUpdate(Offset delta) {
    if (state.selectedElementId != null || state.multiSelectedElementIds.isNotEmpty) {
      moveSelectedElements(delta);
    }
  }

  /// Handle pan end
  void handlePanEnd() {
    _saveToHistory();
  }

  /// Handle double tap on canvas (for text editing)
  void handleCanvasDoubleTap(Offset localPosition) {
    final element = getElementAtPoint(localPosition);
    if (element != null && element.type == ElementType.text) {
      startTextEditing(element.id);
    }
  }

  /// Start editing text element
  void startTextEditing(String elementId) {
    try {
      final element = state.elements.firstWhere(
        (e) => e.id == elementId && e.type == ElementType.text,
      );
      state = state.copyWith(editingTextElementId: elementId);
    } catch (e) {
      // Element not found or not a text element
    }
  }

  /// Stop editing text element
  void stopTextEditing() {
    state = state.copyWith(editingTextElementId: null);
  }

  /// Update text content of editing element
  void updateEditingText(String newText) {
    if (state.editingTextElementId != null) {
      final elementIndex = state.elements.indexWhere(
        (e) => e.id == state.editingTextElementId,
      );
      if (elementIndex >= 0) {
        final element = state.elements[elementIndex];
        if (element is TextElement) {
          final updatedElement = element.copyWith(text: newText);
          final newElements = List<CanvasElement>.from(state.elements);
          newElements[elementIndex] = updatedElement;
          state = state.copyWith(elements: newElements);
        }
      }
    }
  }
  
  // Mobile-specific helper methods
  
  /// Check if running on mobile platform
  bool get _isMobile => !kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS);
  
  /// Touch tolerance for mobile devices (in pixels)
  static const double _touchTolerance = 20.0;
  
  /// Get element at point with touch tolerance for better mobile interaction
  CanvasElement? _getElementAtPointWithTouchTolerance(Offset point) {
    // First try exact hit testing
    final exactElement = getElementAtPoint(point);
    if (exactElement != null) {
      return exactElement;
    }
    
    // If no exact match and we're on mobile, expand the search area
    if (_isMobile) {
      // Check in a square around the touch point
      for (final element in state.elements.reversed) {
        final elementBounds = Rect.fromLTWH(
          element.position.dx - _touchTolerance / 2,
          element.position.dy - _touchTolerance / 2,
          element.size.width + _touchTolerance,
          element.size.height + _touchTolerance,
        );
        
        if (elementBounds.contains(point)) {
          return element;
        }
      }
    }
    
    return null;
  }
  // --- Front/Back side management ---
  void _ensureSideStorage() {
    // Initialize side lists from current state on first use
    if (_frontElements.isEmpty && _backElements.isEmpty) {
      _frontElements = List<CanvasElement>.from(state.elements);
      _backElements = <CanvasElement>[];
      _isFrontSide = true;
    }
  }

  void goToFrontSide() {
    _ensureSideStorage();
    if (!_isFrontSide) {
      _backElements = List<CanvasElement>.from(state.elements);
      _isFrontSide = true;
      state = state.copyWith(
        elements: List<CanvasElement>.from(_frontElements),
        selectedElementId: null,
        multiSelectedElementIds: [],
      );
    }
  }

  void goToBackSide() {
    _ensureSideStorage();
    if (_isFrontSide) {
      _frontElements = List<CanvasElement>.from(state.elements);
      _isFrontSide = false;
      state = state.copyWith(
        elements: List<CanvasElement>.from(_backElements),
        selectedElementId: null,
        multiSelectedElementIds: [],
      );
    }
  }

  void toggleSide() {
    if (_isFrontSide) {
      goToBackSide();
    } else {
      goToFrontSide();
    }
  }
}

/// Provider for canvas state
final canvasProvider = StateNotifierProvider<CanvasNotifier, CanvasState>((ref) {
  return CanvasNotifier();
});

/// Provider for selected element
final selectedElementProvider = Provider<CanvasElement?>((ref) {
  final canvas = ref.watch(canvasProvider);
  if (canvas.selectedElementId != null && canvas.elements.isNotEmpty) {
    return canvas.elements.firstWhere(
      (e) => e.id == canvas.selectedElementId,
      orElse: () => canvas.elements.first,
    );
  }
  return null;
});

/// Provider for canvas elements sorted by z-index
final sortedElementsProvider = Provider<List<CanvasElement>>((ref) {
  final canvas = ref.watch(canvasProvider);
  return canvas.sortedElements;
});
