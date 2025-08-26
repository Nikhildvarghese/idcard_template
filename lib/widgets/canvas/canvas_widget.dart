import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/canvas_element.dart';
import '../../providers/canvas_provider.dart';
import 'element_renderer.dart';
import 'selection_handles.dart';
import 'canvas_background.dart';

/// Main canvas widget that handles rendering and user interactions
class CanvasWidget extends ConsumerWidget {
  const CanvasWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canvasState = ref.watch(canvasProvider);
    final canvasNotifier = ref.read(canvasProvider.notifier);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRect(
        child: Transform(
          alignment: Alignment.topLeft,
          transform: Matrix4.identity()
            ..scale(canvasState.zoom)
            ..translate(canvasState.panOffset.dx, canvasState.panOffset.dy),
          child: Container(
            width: canvasState.canvasSize.width,
            height: canvasState.canvasSize.height,
            child: GestureDetector(
              onTapDown: (details) {
                final localPosition = details.localPosition;
                canvasNotifier.handleCanvasTap(localPosition);
              },
              onDoubleTap: () {
                // Handle double tap separately since we need to track the position
              },
              onDoubleTapDown: (details) {
                final localPosition = details.localPosition;
                canvasNotifier.handleCanvasDoubleTap(localPosition);
              },
              onPanStart: (details) {
                final localPosition = details.localPosition;
                canvasNotifier.handlePanStart(localPosition);
              },
              onPanUpdate: (details) {
                canvasNotifier.handlePanUpdate(details.delta);
              },
              onPanEnd: (details) {
                canvasNotifier.handlePanEnd();
              },
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Canvas background
                  CanvasBackground(
                    size: canvasState.canvasSize,
                    backgroundColor: canvasState.backgroundColor,
                    backgroundImagePath: canvasState.backgroundImagePath,
                    backgroundImageUrl: canvasState.backgroundImageUrl,
                    showGrid: canvasState.isGridVisible,
                    gridSize: canvasState.gridSize,
                  ),
                  
                  // Render all canvas elements
                  ...canvasState.sortedElements.map((element) => 
                    Positioned(
                      left: element.position.dx,
                      top: element.position.dy,
                      child: Transform.rotate(
                        angle: element.rotation,
                        child: Opacity(
                          opacity: element.opacity,
                          child: ElementRenderer(element: element),
                        ),
                      ),
                    ),
                  ).toList(),
                  
                  // Selection handles for selected element
                  if (canvasState.selectedElementId != null) ...[
                    _buildSelectionHandles(canvasState, canvasNotifier),
                  ],
                  
                  // Multi-selection handles
                  ...canvasState.multiSelectedElementIds.map((elementId) {
                    try {
                      final element = canvasState.elements.firstWhere(
                        (e) => e.id == elementId,
                      );
                      return _buildSelectionHandles(canvasState, canvasNotifier, element);
                    } catch (e) {
                      // Element not found, return empty widget
                      return const SizedBox.shrink();
                    }
                  }).toList(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionHandles(
    canvasState, 
    canvasNotifier, 
    [CanvasElement? specificElement]
  ) {
    CanvasElement? element = specificElement;
    
    if (element == null && canvasState.selectedElementId != null) {
      try {
        element = canvasState.elements.firstWhere(
          (e) => e.id == canvasState.selectedElementId,
        );
      } catch (e) {
        // Element not found
        element = null;
      }
    }
    
    if (element == null) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: element.position.dx,
      top: element.position.dy,
      child: Transform.rotate(
        angle: element.rotation,
        child: SelectionHandles(
          element: element,
          onResize: (newSize) {
            canvasNotifier.resizeSelectedElement(newSize);
          },
          onRotate: (rotation) {
            canvasNotifier.rotateSelectedElement(rotation);
          },
          onMove: (delta) {
            canvasNotifier.moveSelectedElements(delta);
          },
        ),
      ),
    );
  }
}

/// Canvas container widget with zoom and pan controls
class CanvasContainer extends ConsumerWidget {
  const CanvasContainer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canvasState = ref.watch(canvasProvider);
    final canvasNotifier = ref.read(canvasProvider.notifier);

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey.shade100,
      child: InteractiveViewer(
        boundaryMargin: const EdgeInsets.all(100),
        minScale: 0.1,
        maxScale: 5.0,
        onInteractionUpdate: (details) {
          // Update canvas zoom and pan state
          canvasNotifier.setZoom(details.scale);
        },
        child: Center(
          child: CanvasWidget(),
        ),
      ),
    );
  }
}

/// Canvas toolbar with common actions
class CanvasToolbar extends ConsumerWidget {
  const CanvasToolbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canvasState = ref.watch(canvasProvider);
    final canvasNotifier = ref.read(canvasProvider.notifier);
    final selectedElement = ref.watch(selectedElementProvider);

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          // Undo/Redo buttons
          IconButton(
            icon: const Icon(Icons.undo),
            onPressed: () => canvasNotifier.undo(),
            tooltip: 'Undo',
          ),
          IconButton(
            icon: const Icon(Icons.redo),
            onPressed: () => canvasNotifier.redo(),
            tooltip: 'Redo',
          ),
          
          const VerticalDivider(),
          
          // Element actions (only show when element is selected)
          if (selectedElement != null) ...[
            IconButton(
              icon: const Icon(Icons.content_copy),
              onPressed: () => canvasNotifier.duplicateSelectedElement(),
              tooltip: 'Duplicate',
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => canvasNotifier.removeElement(selectedElement.id),
              tooltip: 'Delete',
            ),
            
            const VerticalDivider(),
            
            // Layer actions
            IconButton(
              icon: const Icon(Icons.flip_to_front),
              onPressed: () => canvasNotifier.bringToFront(selectedElement.id),
              tooltip: 'Bring to Front',
            ),
            IconButton(
              icon: const Icon(Icons.flip_to_back),
              onPressed: () => canvasNotifier.sendToBack(selectedElement.id),
              tooltip: 'Send to Back',
            ),
          ],
          
          const Spacer(),
          
          // Zoom controls
          Text('${(canvasState.zoom * 100).toStringAsFixed(0)}%'),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.zoom_out),
            onPressed: () => canvasNotifier.setZoom(canvasState.zoom * 0.8),
            tooltip: 'Zoom Out',
          ),
          IconButton(
            icon: const Icon(Icons.zoom_in),
            onPressed: () => canvasNotifier.setZoom(canvasState.zoom * 1.25),
            tooltip: 'Zoom In',
          ),
          
          const VerticalDivider(),
          
          // Grid toggle
          IconButton(
            icon: Icon(
              Icons.grid_4x4,
              color: canvasState.isGridVisible ? Colors.blue : null,
            ),
            onPressed: () => canvasNotifier.toggleGrid(),
            tooltip: 'Toggle Grid',
          ),
          
          // Snap to grid toggle
          IconButton(
            icon: Icon(
              Icons.dashboard,
              color: canvasState.isSnapToGrid ? Colors.blue : null,
            ),
            onPressed: () => canvasNotifier.toggleSnapToGrid(),
            tooltip: 'Snap to Grid',
          ),
        ],
      ),
    );
  }
}
