// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'canvas_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CanvasState _$CanvasStateFromJson(Map<String, dynamic> json) => CanvasState(
  canvasSize: json['canvasSize'] == null
      ? const Size(400, 600)
      : const SizeConverter().fromJson(
          json['canvasSize'] as Map<String, dynamic>,
        ),
  elements:
      (json['elements'] as List<dynamic>?)
          ?.map((e) => CanvasElement.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  selectedElementId: json['selectedElementId'] as String?,
  multiSelectedElementIds:
      (json['multiSelectedElementIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  backgroundColor: json['backgroundColor'] == null
      ? const Color(0xFFFFFFFF)
      : const ColorConverter().fromJson(
          (json['backgroundColor'] as num).toInt(),
        ),
  zoom: (json['zoom'] as num?)?.toDouble() ?? 1.0,
  panOffset: json['panOffset'] == null
      ? Offset.zero
      : const OffsetConverter().fromJson(
          json['panOffset'] as Map<String, dynamic>,
        ),
  isGridVisible: json['isGridVisible'] as bool? ?? false,
  gridSize: (json['gridSize'] as num?)?.toDouble() ?? 10.0,
  isSnapToGrid: json['isSnapToGrid'] as bool? ?? false,
  history:
      (json['history'] as List<dynamic>?)
          ?.map((e) => CanvasState.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  historyIndex: (json['historyIndex'] as num?)?.toInt() ?? 0,
  backgroundImagePath: json['backgroundImagePath'] as String?,
  backgroundImageUrl: json['backgroundImageUrl'] as String?,
  editingTextElementId: json['editingTextElementId'] as String?,
);

Map<String, dynamic> _$CanvasStateToJson(
  CanvasState instance,
) => <String, dynamic>{
  'canvasSize': const SizeConverter().toJson(instance.canvasSize),
  'elements': instance.elements,
  'selectedElementId': instance.selectedElementId,
  'multiSelectedElementIds': instance.multiSelectedElementIds,
  'backgroundColor': const ColorConverter().toJson(instance.backgroundColor),
  'zoom': instance.zoom,
  'panOffset': const OffsetConverter().toJson(instance.panOffset),
  'isGridVisible': instance.isGridVisible,
  'gridSize': instance.gridSize,
  'isSnapToGrid': instance.isSnapToGrid,
  'history': instance.history,
  'historyIndex': instance.historyIndex,
  'backgroundImagePath': instance.backgroundImagePath,
  'backgroundImageUrl': instance.backgroundImageUrl,
  'editingTextElementId': instance.editingTextElementId,
};
