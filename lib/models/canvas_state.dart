import 'dart:math' as math;
import 'dart:ui';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'canvas_element.dart';
import '../utils/json_converters.dart';

part 'canvas_state.g.dart';

/// Canvas state that holds all elements and canvas properties
@JsonSerializable()
class CanvasState extends Equatable {
  @SizeConverter()
  final Size canvasSize;
  final List<CanvasElement> elements;
  final String? selectedElementId;
  final List<String> multiSelectedElementIds;
  @ColorConverter()
  final Color backgroundColor;
  final double zoom;
  @OffsetConverter()
  final Offset panOffset;
  final bool isGridVisible;
  final double gridSize;
  final bool isSnapToGrid;
  final List<CanvasState> history;
  final int historyIndex;
  final String? backgroundImagePath;
  final String? backgroundImageUrl;
  final String? editingTextElementId;

  const CanvasState({
    this.canvasSize = const Size(400, 600), // Default ID card size
    this.elements = const [],
    this.selectedElementId,
    this.multiSelectedElementIds = const [],
    this.backgroundColor = const Color(0xFFFFFFFF),
    this.zoom = 1.0,
    this.panOffset = Offset.zero,
    this.isGridVisible = false,
    this.gridSize = 10.0,
    this.isSnapToGrid = false,
    this.history = const [],
    this.historyIndex = 0,
    this.backgroundImagePath,
    this.backgroundImageUrl,
    this.editingTextElementId,
  });

  factory CanvasState.fromJson(Map<String, dynamic> json) =>
      _$CanvasStateFromJson(json);

  Map<String, dynamic> toJson() => _$CanvasStateToJson(this);

  /// Create an empty canvas with default settings
  factory CanvasState.empty() {
    return const CanvasState();
  }

  /// Get all selected elements
  List<CanvasElement> get selectedElements {
    if (selectedElementId != null) {
      final element = elements.firstWhere(
        (e) => e.id == selectedElementId,
        orElse: () => elements.first,
      );
      return [element];
    }

    return elements
        .where((e) => multiSelectedElementIds.contains(e.id))
        .toList();
  }

  /// Get elements sorted by z-index
  List<CanvasElement> get sortedElements {
    final sorted = List<CanvasElement>.from(elements);
    sorted.sort((a, b) => a.zIndex.compareTo(b.zIndex));
    return sorted;
  }

  /// Add a new element to the canvas
  CanvasState addElement(CanvasElement element) {
    final newElements = List<CanvasElement>.from(elements);
    newElements.add(element);

    return copyWith(
      elements: newElements,
      selectedElementId: element.id,
      multiSelectedElementIds: [],
    );
  }

  /// Remove an element from the canvas
  CanvasState removeElement(String elementId) {
    final newElements = elements.where((e) => e.id != elementId).toList();

    return copyWith(
      elements: newElements,
      selectedElementId: selectedElementId == elementId ? null : selectedElementId,
      multiSelectedElementIds: multiSelectedElementIds
          .where((id) => id != elementId)
          .toList(),
    );
  }

  /// Update an existing element
  CanvasState updateElement(CanvasElement updatedElement) {
    final newElements = elements.map((e) {
      if (e.id == updatedElement.id) {
        return updatedElement;
      }
      return e;
    }).toList();

    return copyWith(elements: newElements);
  }

  /// Select a single element
  CanvasState selectElement(String? elementId) {
    return copyWith(
      selectedElementId: elementId,
      multiSelectedElementIds: [],
    );
  }

  /// Add element to multi-selection
  CanvasState addToMultiSelection(String elementId) {
    if (multiSelectedElementIds.contains(elementId)) {
      return this;
    }

    return copyWith(
      selectedElementId: null,
      multiSelectedElementIds: [...multiSelectedElementIds, elementId],
    );
  }

  /// Remove element from multi-selection
  CanvasState removeFromMultiSelection(String elementId) {
    final newMultiSelected = multiSelectedElementIds
        .where((id) => id != elementId)
        .toList();

    return copyWith(
      multiSelectedElementIds: newMultiSelected,
    );
  }

  /// Clear all selections
  CanvasState clearSelection() {
    return copyWith(
      selectedElementId: null,
      multiSelectedElementIds: [],
    );
  }

  /// Deselect all elements (mark them as not selected)
  CanvasState deselectAllElements() {
    final newElements = elements.map((e) {
      if (e.isSelected) {
        return e.copyWith(isSelected: false);
      }
      return e;
    }).toList();

    return copyWith(
      elements: newElements,
      selectedElementId: null,
      multiSelectedElementIds: [],
    );
  }

  /// Move selected elements
  CanvasState moveSelectedElements(Offset delta) {
    final selectedIds = selectedElementId != null
        ? [selectedElementId!]
        : multiSelectedElementIds;

    final newElements = elements.map((e) {
      if (selectedIds.contains(e.id) && !e.isLocked) {
        final newPosition = e.position + delta;
        
        // Apply snap-to-grid if enabled
        final finalPosition = isSnapToGrid ? _snapToGrid(newPosition) : newPosition;
        
        // Ensure element stays within canvas bounds
        final maxX = math.max(0.0, canvasSize.width - e.size.width);
        final maxY = math.max(0.0, canvasSize.height - e.size.height);
        final clampedPosition = Offset(
          finalPosition.dx.clamp(0.0, maxX),
          finalPosition.dy.clamp(0.0, maxY),
        );
        return e.copyWith(position: clampedPosition);
      }
      return e;
    }).toList();

    return copyWith(elements: newElements);
  }
  
  /// Snap position to grid
  Offset _snapToGrid(Offset position) {
    final snappedX = (position.dx / gridSize).round() * gridSize;
    final snappedY = (position.dy / gridSize).round() * gridSize;
    return Offset(snappedX, snappedY);
  }

  /// Resize selected element
  CanvasState resizeSelectedElement(Size newSize) {
    if (selectedElementId == null) return this;

    final newElements = elements.map((e) {
      if (e.id == selectedElementId && !e.isLocked) {
        return e.copyWith(size: newSize);
      }
      return e;
    }).toList();

    return copyWith(elements: newElements);
  }

  /// Rotate selected element
  CanvasState rotateSelectedElement(double rotation) {
    if (selectedElementId == null) return this;

    final newElements = elements.map((e) {
      if (e.id == selectedElementId && !e.isLocked) {
        return e.copyWith(rotation: rotation);
      }
      return e;
    }).toList();

    return copyWith(elements: newElements);
  }

  /// Bring element to front
  CanvasState bringToFront(String elementId) {
    final maxZ = elements.isEmpty ? 0 : elements.map((e) => e.zIndex).reduce((a, b) => a > b ? a : b);
    
    final newElements = elements.map((e) {
      if (e.id == elementId) {
        return e.copyWith(zIndex: maxZ + 1);
      }
      return e;
    }).toList();

    return copyWith(elements: newElements);
  }

  /// Send element to back
  CanvasState sendToBack(String elementId) {
    final minZ = elements.isEmpty ? 0 : elements.map((e) => e.zIndex).reduce((a, b) => a < b ? a : b);
    
    final newElements = elements.map((e) {
      if (e.id == elementId) {
        return e.copyWith(zIndex: minZ - 1);
      }
      return e;
    }).toList();

    return copyWith(elements: newElements);
  }

  /// Duplicate selected element
  CanvasState duplicateSelectedElement() {
    if (selectedElementId == null) return this;

    final elementToDuplicate = elements.firstWhere(
      (e) => e.id == selectedElementId,
      orElse: () => elements.first,
    );

    // Create a copy with new ID and offset position
    CanvasElement duplicatedElement;
    final newId = ElementIdGenerator.generate();
    final offset = const Offset(10, 10);

    switch (elementToDuplicate.type) {
      case ElementType.text:
        final textElement = elementToDuplicate as TextElement;
        duplicatedElement = textElement.copyWith(
          id: newId,
          position: elementToDuplicate.position + offset,
          isSelected: false,
        );
        break;
      case ElementType.image:
        final imageElement = elementToDuplicate as ImageElement;
        duplicatedElement = imageElement.copyWith(
          id: newId,
          position: elementToDuplicate.position + offset,
          isSelected: false,
        );
        break;
      case ElementType.shape:
        final shapeElement = elementToDuplicate as ShapeElement;
        duplicatedElement = shapeElement.copyWith(
          id: newId,
          position: elementToDuplicate.position + offset,
          isSelected: false,
        );
        break;
      case ElementType.line:
        final lineElement = elementToDuplicate as LineElement;
        duplicatedElement = lineElement.copyWith(
          id: newId,
          startPoint: lineElement.startPoint + offset,
          endPoint: lineElement.endPoint + offset,
          isSelected: false,
        );
        break;
      case ElementType.background:
        // Don't duplicate background elements
        return this;
    }

    return addElement(duplicatedElement);
  }

  /// Get element at a specific point
  CanvasElement? getElementAtPoint(Offset point) {
    // Search from top to bottom (highest z-index first)
    final sortedByZ = List<CanvasElement>.from(elements);
    sortedByZ.sort((a, b) => b.zIndex.compareTo(a.zIndex));

    for (final element in sortedByZ) {
      if (element.containsPoint(point)) {
        return element;
      }
    }
    return null;
  }

  /// Zoom in/out
  CanvasState setZoom(double newZoom) {
    return copyWith(zoom: newZoom.clamp(0.1, 5.0));
  }

  /// Pan the canvas
  CanvasState setPan(Offset newPanOffset) {
    return copyWith(panOffset: newPanOffset);
  }

  /// Toggle grid visibility
  CanvasState toggleGrid() {
    return copyWith(isGridVisible: !isGridVisible);
  }

  /// Toggle snap to grid
  CanvasState toggleSnapToGrid() {
    return copyWith(isSnapToGrid: !isSnapToGrid);
  }

  /// Set canvas size
  CanvasState setCanvasSize(Size newSize) {
    return copyWith(canvasSize: newSize);
  }

  /// Set background color
  CanvasState setBackgroundColor(Color color) {
    return copyWith(backgroundColor: color);
  }

  /// Set background image
  CanvasState setBackgroundImage({String? imagePath, String? imageUrl}) {
    return copyWith(
      backgroundImagePath: imagePath,
      backgroundImageUrl: imageUrl,
    );
  }

  /// Clear background image
  CanvasState clearBackgroundImage() {
    return copyWith(
      backgroundImagePath: null,
      backgroundImageUrl: null,
    );
  }

  @override
  CanvasState copyWith({
    Size? canvasSize,
    List<CanvasElement>? elements,
    String? selectedElementId,
    List<String>? multiSelectedElementIds,
    Color? backgroundColor,
    double? zoom,
    Offset? panOffset,
    bool? isGridVisible,
    double? gridSize,
    bool? isSnapToGrid,
    List<CanvasState>? history,
    int? historyIndex,
    String? backgroundImagePath,
    String? backgroundImageUrl,
    String? editingTextElementId,
  }) {
    return CanvasState(
      canvasSize: canvasSize ?? this.canvasSize,
      elements: elements ?? this.elements,
      selectedElementId: selectedElementId ?? this.selectedElementId,
      multiSelectedElementIds: multiSelectedElementIds ?? this.multiSelectedElementIds,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      zoom: zoom ?? this.zoom,
      panOffset: panOffset ?? this.panOffset,
      isGridVisible: isGridVisible ?? this.isGridVisible,
      gridSize: gridSize ?? this.gridSize,
      isSnapToGrid: isSnapToGrid ?? this.isSnapToGrid,
      history: history ?? this.history,
      historyIndex: historyIndex ?? this.historyIndex,
      backgroundImagePath: backgroundImagePath ?? this.backgroundImagePath,
      backgroundImageUrl: backgroundImageUrl ?? this.backgroundImageUrl,
      editingTextElementId: editingTextElementId ?? this.editingTextElementId,
    );
  }

  @override
  List<Object?> get props => [
        canvasSize,
        elements,
        selectedElementId,
        multiSelectedElementIds,
        backgroundColor,
        zoom,
        panOffset,
        isGridVisible,
        gridSize,
        isSnapToGrid,
        history,
        historyIndex,
        backgroundImagePath,
        backgroundImageUrl,
        editingTextElementId,
      ];
}
