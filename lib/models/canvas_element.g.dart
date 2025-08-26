// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'canvas_element.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TextElement _$TextElementFromJson(Map<String, dynamic> json) => TextElement(
  id: json['id'] as String,
  position: const OffsetConverter().fromJson(
    json['position'] as Map<String, dynamic>,
  ),
  size: const SizeConverter().fromJson(json['size'] as Map<String, dynamic>),
  text: json['text'] as String,
  fontFamily: json['fontFamily'] as String? ?? 'Roboto',
  fontSize: (json['fontSize'] as num?)?.toDouble() ?? 16.0,
  color: json['color'] == null
      ? const Color(0xFF000000)
      : const ColorConverter().fromJson((json['color'] as num).toInt()),
  fontWeight: json['fontWeight'] == null
      ? FontWeight.normal
      : const FontWeightConverter().fromJson(
          (json['fontWeight'] as num).toInt(),
        ),
  fontStyle: json['fontStyle'] == null
      ? FontStyle.normal
      : const FontStyleConverter().fromJson(json['fontStyle'] as String),
  textAlign: json['textAlign'] == null
      ? TextAlign.left
      : const TextAlignConverter().fromJson(json['textAlign'] as String),
  textDecoration: json['textDecoration'] == null
      ? TextDecoration.none
      : const TextDecorationConverter().fromJson(
          json['textDecoration'] as String,
        ),
  letterSpacing: (json['letterSpacing'] as num?)?.toDouble() ?? 0.0,
  lineHeight: (json['lineHeight'] as num?)?.toDouble() ?? 1.0,
  rotation: (json['rotation'] as num?)?.toDouble() ?? 0.0,
  isSelected: json['isSelected'] as bool? ?? false,
  isLocked: json['isLocked'] as bool? ?? false,
  zIndex: (json['zIndex'] as num?)?.toInt() ?? 0,
  opacity: (json['opacity'] as num?)?.toDouble() ?? 1.0,
);

Map<String, dynamic> _$TextElementToJson(TextElement instance) =>
    <String, dynamic>{
      'id': instance.id,
      'position': const OffsetConverter().toJson(instance.position),
      'size': const SizeConverter().toJson(instance.size),
      'rotation': instance.rotation,
      'isSelected': instance.isSelected,
      'isLocked': instance.isLocked,
      'zIndex': instance.zIndex,
      'opacity': instance.opacity,
      'text': instance.text,
      'fontFamily': instance.fontFamily,
      'fontSize': instance.fontSize,
      'color': const ColorConverter().toJson(instance.color),
      'fontWeight': const FontWeightConverter().toJson(instance.fontWeight),
      'fontStyle': const FontStyleConverter().toJson(instance.fontStyle),
      'textAlign': const TextAlignConverter().toJson(instance.textAlign),
      'textDecoration': const TextDecorationConverter().toJson(
        instance.textDecoration,
      ),
      'letterSpacing': instance.letterSpacing,
      'lineHeight': instance.lineHeight,
    };

ImageElement _$ImageElementFromJson(Map<String, dynamic> json) => ImageElement(
  id: json['id'] as String,
  position: const OffsetConverter().fromJson(
    json['position'] as Map<String, dynamic>,
  ),
  size: const SizeConverter().fromJson(json['size'] as Map<String, dynamic>),
  imagePath: json['imagePath'] as String,
  imageUrl: json['imageUrl'] as String?,
  fit: json['fit'] == null
      ? BoxFit.cover
      : const BoxFitConverter().fromJson(json['fit'] as String),
  borderRadius: (json['borderRadius'] as num?)?.toDouble() ?? 0.0,
  borderColor: const NullableColorConverter().fromJson(
    (json['borderColor'] as num?)?.toInt(),
  ),
  borderWidth: (json['borderWidth'] as num?)?.toDouble() ?? 0.0,
  rotation: (json['rotation'] as num?)?.toDouble() ?? 0.0,
  isSelected: json['isSelected'] as bool? ?? false,
  isLocked: json['isLocked'] as bool? ?? false,
  zIndex: (json['zIndex'] as num?)?.toInt() ?? 0,
  opacity: (json['opacity'] as num?)?.toDouble() ?? 1.0,
);

Map<String, dynamic> _$ImageElementToJson(
  ImageElement instance,
) => <String, dynamic>{
  'id': instance.id,
  'position': const OffsetConverter().toJson(instance.position),
  'size': const SizeConverter().toJson(instance.size),
  'rotation': instance.rotation,
  'isSelected': instance.isSelected,
  'isLocked': instance.isLocked,
  'zIndex': instance.zIndex,
  'opacity': instance.opacity,
  'imagePath': instance.imagePath,
  'imageUrl': instance.imageUrl,
  'fit': const BoxFitConverter().toJson(instance.fit),
  'borderRadius': instance.borderRadius,
  'borderColor': const NullableColorConverter().toJson(instance.borderColor),
  'borderWidth': instance.borderWidth,
};

ShapeElement _$ShapeElementFromJson(Map<String, dynamic> json) => ShapeElement(
  id: json['id'] as String,
  position: const OffsetConverter().fromJson(
    json['position'] as Map<String, dynamic>,
  ),
  size: const SizeConverter().fromJson(json['size'] as Map<String, dynamic>),
  shapeType: $enumDecode(_$ShapeTypeEnumMap, json['shapeType']),
  fillColor: json['fillColor'] == null
      ? const Color(0xFF000000)
      : const ColorConverter().fromJson((json['fillColor'] as num).toInt()),
  strokeColor: const NullableColorConverter().fromJson(
    (json['strokeColor'] as num?)?.toInt(),
  ),
  strokeWidth: (json['strokeWidth'] as num?)?.toDouble() ?? 0.0,
  borderRadius: (json['borderRadius'] as num?)?.toDouble() ?? 0.0,
  rotation: (json['rotation'] as num?)?.toDouble() ?? 0.0,
  isSelected: json['isSelected'] as bool? ?? false,
  isLocked: json['isLocked'] as bool? ?? false,
  zIndex: (json['zIndex'] as num?)?.toInt() ?? 0,
  opacity: (json['opacity'] as num?)?.toDouble() ?? 1.0,
);

Map<String, dynamic> _$ShapeElementToJson(
  ShapeElement instance,
) => <String, dynamic>{
  'id': instance.id,
  'position': const OffsetConverter().toJson(instance.position),
  'size': const SizeConverter().toJson(instance.size),
  'rotation': instance.rotation,
  'isSelected': instance.isSelected,
  'isLocked': instance.isLocked,
  'zIndex': instance.zIndex,
  'opacity': instance.opacity,
  'shapeType': _$ShapeTypeEnumMap[instance.shapeType]!,
  'fillColor': const ColorConverter().toJson(instance.fillColor),
  'strokeColor': const NullableColorConverter().toJson(instance.strokeColor),
  'strokeWidth': instance.strokeWidth,
  'borderRadius': instance.borderRadius,
};

const _$ShapeTypeEnumMap = {
  ShapeType.rectangle: 'rectangle',
  ShapeType.circle: 'circle',
  ShapeType.triangle: 'triangle',
  ShapeType.star: 'star',
  ShapeType.polygon: 'polygon',
};

LineElement _$LineElementFromJson(Map<String, dynamic> json) => LineElement(
  id: json['id'] as String,
  startPoint: const OffsetConverter().fromJson(
    json['startPoint'] as Map<String, dynamic>,
  ),
  endPoint: const OffsetConverter().fromJson(
    json['endPoint'] as Map<String, dynamic>,
  ),
  color: json['color'] == null
      ? const Color(0xFF000000)
      : const ColorConverter().fromJson((json['color'] as num).toInt()),
  strokeWidth: (json['strokeWidth'] as num?)?.toDouble() ?? 2.0,
  strokeCap: json['strokeCap'] == null
      ? StrokeCap.round
      : const StrokeCapConverter().fromJson(json['strokeCap'] as String),
  rotation: (json['rotation'] as num?)?.toDouble() ?? 0.0,
  isSelected: json['isSelected'] as bool? ?? false,
  isLocked: json['isLocked'] as bool? ?? false,
  zIndex: (json['zIndex'] as num?)?.toInt() ?? 0,
  opacity: (json['opacity'] as num?)?.toDouble() ?? 1.0,
);

Map<String, dynamic> _$LineElementToJson(LineElement instance) =>
    <String, dynamic>{
      'id': instance.id,
      'rotation': instance.rotation,
      'isSelected': instance.isSelected,
      'isLocked': instance.isLocked,
      'zIndex': instance.zIndex,
      'opacity': instance.opacity,
      'startPoint': const OffsetConverter().toJson(instance.startPoint),
      'endPoint': const OffsetConverter().toJson(instance.endPoint),
      'color': const ColorConverter().toJson(instance.color),
      'strokeWidth': instance.strokeWidth,
      'strokeCap': const StrokeCapConverter().toJson(instance.strokeCap),
    };

BackgroundElement _$BackgroundElementFromJson(Map<String, dynamic> json) =>
    BackgroundElement(
      id: json['id'] as String,
      size: const SizeConverter().fromJson(
        json['size'] as Map<String, dynamic>,
      ),
      color: json['color'] == null
          ? const Color(0xFFFFFFFF)
          : const ColorConverter().fromJson((json['color'] as num).toInt()),
      imageUrl: json['imageUrl'] as String?,
      imagePath: json['imagePath'] as String?,
      fit: json['fit'] == null
          ? BoxFit.cover
          : const BoxFitConverter().fromJson(json['fit'] as String),
    );

Map<String, dynamic> _$BackgroundElementToJson(BackgroundElement instance) =>
    <String, dynamic>{
      'id': instance.id,
      'size': const SizeConverter().toJson(instance.size),
      'color': const ColorConverter().toJson(instance.color),
      'imageUrl': instance.imageUrl,
      'imagePath': instance.imagePath,
      'fit': const BoxFitConverter().toJson(instance.fit),
    };
