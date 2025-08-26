import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';
import '../utils/json_converters.dart';

part 'canvas_element.g.dart';

/// Enum for different types of canvas elements
enum ElementType {
  text,
  image,
  shape,
  line,
  background,
}

/// Base class for all canvas elements
abstract class CanvasElement extends Equatable {
  final String id;
  final ElementType type;
  @OffsetConverter()
  final Offset position;
  @SizeConverter()
  final Size size;
  final double rotation;
  final bool isSelected;
  final bool isLocked;
  final int zIndex;
  final double opacity;

  const CanvasElement({
    required this.id,
    required this.type,
    required this.position,
    required this.size,
    this.rotation = 0.0,
    this.isSelected = false,
    this.isLocked = false,
    this.zIndex = 0,
    this.opacity = 1.0,
  });

  factory CanvasElement.fromJson(Map<String, dynamic> json) {
    switch (json['type'] as String) {
      case 'text':
        return TextElement.fromJson(json);
      case 'image':
        return ImageElement.fromJson(json);
      case 'shape':
        return ShapeElement.fromJson(json);
      case 'line':
        return LineElement.fromJson(json);
      case 'background':
        return BackgroundElement.fromJson(json);
      default:
        throw ArgumentError('Unknown element type: ${json['type']}');
    }
  }

  Map<String, dynamic> toJson();

  /// Create a copy of this element with updated properties
  CanvasElement copyWith({
    String? id,
    Offset? position,
    Size? size,
    double? rotation,
    bool? isSelected,
    bool? isLocked,
    int? zIndex,
    double? opacity,
  });

  /// Get the bounds rectangle of this element
  Rect get bounds => Rect.fromLTWH(
        position.dx,
        position.dy,
        size.width,
        size.height,
      );

  /// Check if a point is inside this element
  bool containsPoint(Offset point) {
    return bounds.contains(point);
  }

  @override
  List<Object?> get props => [
        id,
        type,
        position,
        size,
        rotation,
        isSelected,
        isLocked,
        zIndex,
        opacity,
      ];
}

/// Text element for canvas
@JsonSerializable()
class TextElement extends CanvasElement {
  final String text;
  final String fontFamily;
  final double fontSize;
  @ColorConverter()
  final Color color;
  @FontWeightConverter()
  final FontWeight fontWeight;
  @FontStyleConverter()
  final FontStyle fontStyle;
  @TextAlignConverter()
  final TextAlign textAlign;
  @TextDecorationConverter()
  final TextDecoration textDecoration;
  final double letterSpacing;
  final double lineHeight;

  const TextElement({
    required String id,
    required Offset position,
    required Size size,
    required this.text,
    this.fontFamily = 'Roboto',
    this.fontSize = 16.0,
    this.color = const Color(0xFF000000),
    this.fontWeight = FontWeight.normal,
    this.fontStyle = FontStyle.normal,
    this.textAlign = TextAlign.left,
    this.textDecoration = TextDecoration.none,
    this.letterSpacing = 0.0,
    this.lineHeight = 1.0,
    double rotation = 0.0,
    bool isSelected = false,
    bool isLocked = false,
    int zIndex = 0,
    double opacity = 1.0,
  }) : super(
          id: id,
          type: ElementType.text,
          position: position,
          size: size,
          rotation: rotation,
          isSelected: isSelected,
          isLocked: isLocked,
          zIndex: zIndex,
          opacity: opacity,
        );

  factory TextElement.fromJson(Map<String, dynamic> json) =>
      _$TextElementFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$TextElementToJson(this);

  @override
  TextElement copyWith({
    String? id,
    Offset? position,
    Size? size,
    String? text,
    String? fontFamily,
    double? fontSize,
    Color? color,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    TextAlign? textAlign,
    TextDecoration? textDecoration,
    double? letterSpacing,
    double? lineHeight,
    double? rotation,
    bool? isSelected,
    bool? isLocked,
    int? zIndex,
    double? opacity,
  }) {
    return TextElement(
      id: id ?? this.id,
      position: position ?? this.position,
      size: size ?? this.size,
      text: text ?? this.text,
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      color: color ?? this.color,
      fontWeight: fontWeight ?? this.fontWeight,
      fontStyle: fontStyle ?? this.fontStyle,
      textAlign: textAlign ?? this.textAlign,
      textDecoration: textDecoration ?? this.textDecoration,
      letterSpacing: letterSpacing ?? this.letterSpacing,
      lineHeight: lineHeight ?? this.lineHeight,
      rotation: rotation ?? this.rotation,
      isSelected: isSelected ?? this.isSelected,
      isLocked: isLocked ?? this.isLocked,
      zIndex: zIndex ?? this.zIndex,
      opacity: opacity ?? this.opacity,
    );
  }

  @override
  List<Object?> get props => super.props +
      [
        text,
        fontFamily,
        fontSize,
        color,
        fontWeight,
        fontStyle,
        textAlign,
        textDecoration,
        letterSpacing,
        lineHeight,
      ];
}

/// Image element for canvas
@JsonSerializable()
class ImageElement extends CanvasElement {
  final String imagePath;
  final String? imageUrl;
  @BoxFitConverter()
  final BoxFit fit;
  final double borderRadius;
  @NullableColorConverter()
  final Color? borderColor;
  final double borderWidth;

  const ImageElement({
    required String id,
    required Offset position,
    required Size size,
    required this.imagePath,
    this.imageUrl,
    this.fit = BoxFit.cover,
    this.borderRadius = 0.0,
    this.borderColor,
    this.borderWidth = 0.0,
    double rotation = 0.0,
    bool isSelected = false,
    bool isLocked = false,
    int zIndex = 0,
    double opacity = 1.0,
  }) : super(
          id: id,
          type: ElementType.image,
          position: position,
          size: size,
          rotation: rotation,
          isSelected: isSelected,
          isLocked: isLocked,
          zIndex: zIndex,
          opacity: opacity,
        );

  factory ImageElement.fromJson(Map<String, dynamic> json) =>
      _$ImageElementFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ImageElementToJson(this);

  @override
  ImageElement copyWith({
    String? id,
    Offset? position,
    Size? size,
    String? imagePath,
    String? imageUrl,
    BoxFit? fit,
    double? borderRadius,
    Color? borderColor,
    double? borderWidth,
    double? rotation,
    bool? isSelected,
    bool? isLocked,
    int? zIndex,
    double? opacity,
  }) {
    return ImageElement(
      id: id ?? this.id,
      position: position ?? this.position,
      size: size ?? this.size,
      imagePath: imagePath ?? this.imagePath,
      imageUrl: imageUrl ?? this.imageUrl,
      fit: fit ?? this.fit,
      borderRadius: borderRadius ?? this.borderRadius,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      rotation: rotation ?? this.rotation,
      isSelected: isSelected ?? this.isSelected,
      isLocked: isLocked ?? this.isLocked,
      zIndex: zIndex ?? this.zIndex,
      opacity: opacity ?? this.opacity,
    );
  }

  @override
  List<Object?> get props => super.props +
      [
        imagePath,
        imageUrl,
        fit,
        borderRadius,
        borderColor,
        borderWidth,
      ];
}

/// Shape types enum
enum ShapeType {
  rectangle,
  circle,
  triangle,
  star,
  polygon,
}

/// Shape element for canvas
@JsonSerializable()
class ShapeElement extends CanvasElement {
  final ShapeType shapeType;
  @ColorConverter()
  final Color fillColor;
  @NullableColorConverter()
  final Color? strokeColor;
  final double strokeWidth;
  final double borderRadius;

  const ShapeElement({
    required String id,
    required Offset position,
    required Size size,
    required this.shapeType,
    this.fillColor = const Color(0xFF000000),
    this.strokeColor,
    this.strokeWidth = 0.0,
    this.borderRadius = 0.0,
    double rotation = 0.0,
    bool isSelected = false,
    bool isLocked = false,
    int zIndex = 0,
    double opacity = 1.0,
  }) : super(
          id: id,
          type: ElementType.shape,
          position: position,
          size: size,
          rotation: rotation,
          isSelected: isSelected,
          isLocked: isLocked,
          zIndex: zIndex,
          opacity: opacity,
        );

  factory ShapeElement.fromJson(Map<String, dynamic> json) =>
      _$ShapeElementFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ShapeElementToJson(this);

  @override
  ShapeElement copyWith({
    String? id,
    Offset? position,
    Size? size,
    ShapeType? shapeType,
    Color? fillColor,
    Color? strokeColor,
    double? strokeWidth,
    double? borderRadius,
    double? rotation,
    bool? isSelected,
    bool? isLocked,
    int? zIndex,
    double? opacity,
  }) {
    return ShapeElement(
      id: id ?? this.id,
      position: position ?? this.position,
      size: size ?? this.size,
      shapeType: shapeType ?? this.shapeType,
      fillColor: fillColor ?? this.fillColor,
      strokeColor: strokeColor ?? this.strokeColor,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      borderRadius: borderRadius ?? this.borderRadius,
      rotation: rotation ?? this.rotation,
      isSelected: isSelected ?? this.isSelected,
      isLocked: isLocked ?? this.isLocked,
      zIndex: zIndex ?? this.zIndex,
      opacity: opacity ?? this.opacity,
    );
  }

  @override
  List<Object?> get props => super.props +
      [
        shapeType,
        fillColor,
        strokeColor,
        strokeWidth,
        borderRadius,
      ];
}

/// Line element for canvas
@JsonSerializable()
class LineElement extends CanvasElement {
  @OffsetConverter()
  final Offset startPoint;
  @OffsetConverter()
  final Offset endPoint;
  @ColorConverter()
  final Color color;
  final double strokeWidth;
  @StrokeCapConverter()
  final StrokeCap strokeCap;

  LineElement({
    required String id,
    required this.startPoint,
    required this.endPoint,
    this.color = const Color(0xFF000000),
    this.strokeWidth = 2.0,
    this.strokeCap = StrokeCap.round,
    double rotation = 0.0,
    bool isSelected = false,
    bool isLocked = false,
    int zIndex = 0,
    double opacity = 1.0,
  }) : super(
          id: id,
          type: ElementType.line,
          position: startPoint,
          size: Size(
            (endPoint.dx - startPoint.dx).abs(),
            (endPoint.dy - startPoint.dy).abs(),
          ),
          rotation: rotation,
          isSelected: isSelected,
          isLocked: isLocked,
          zIndex: zIndex,
          opacity: opacity,
        );

  factory LineElement.fromJson(Map<String, dynamic> json) =>
      _$LineElementFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$LineElementToJson(this);

  @override
  LineElement copyWith({
    String? id,
    Offset? position,
    Size? size,
    Offset? startPoint,
    Offset? endPoint,
    Color? color,
    double? strokeWidth,
    StrokeCap? strokeCap,
    double? rotation,
    bool? isSelected,
    bool? isLocked,
    int? zIndex,
    double? opacity,
  }) {
    return LineElement(
      id: id ?? this.id,
      startPoint: startPoint ?? this.startPoint,
      endPoint: endPoint ?? this.endPoint,
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      strokeCap: strokeCap ?? this.strokeCap,
      rotation: rotation ?? this.rotation,
      isSelected: isSelected ?? this.isSelected,
      isLocked: isLocked ?? this.isLocked,
      zIndex: zIndex ?? this.zIndex,
      opacity: opacity ?? this.opacity,
    );
  }

  @override
  List<Object?> get props => super.props +
      [
        startPoint,
        endPoint,
        color,
        strokeWidth,
        strokeCap,
      ];
}

/// Background element for canvas
@JsonSerializable()
class BackgroundElement extends CanvasElement {
  @ColorConverter()
  final Color color;
  final String? imageUrl;
  final String? imagePath;
  @BoxFitConverter()
  final BoxFit fit;

  const BackgroundElement({
    required String id,
    required Size size,
    this.color = const Color(0xFFFFFFFF),
    this.imageUrl,
    this.imagePath,
    this.fit = BoxFit.cover,
  }) : super(
          id: id,
          type: ElementType.background,
          position: Offset.zero,
          size: size,
          rotation: 0.0,
          isSelected: false,
          isLocked: false,
          zIndex: -1000,
          opacity: 1.0,
        );

  factory BackgroundElement.fromJson(Map<String, dynamic> json) =>
      _$BackgroundElementFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$BackgroundElementToJson(this);

  @override
  BackgroundElement copyWith({
    String? id,
    Offset? position,
    Size? size,
    double? rotation,
    bool? isSelected,
    bool? isLocked,
    int? zIndex,
    double? opacity,
    Color? color,
    String? imageUrl,
    String? imagePath,
    BoxFit? fit,
  }) {
    return BackgroundElement(
      id: id ?? this.id,
      size: size ?? this.size,
      color: color ?? this.color,
      imageUrl: imageUrl ?? this.imageUrl,
      imagePath: imagePath ?? this.imagePath,
      fit: fit ?? this.fit,
    );
  }

  @override
  List<Object?> get props => super.props +
      [
        color,
        imageUrl,
        imagePath,
        fit,
      ];
}

/// Helper class to generate unique IDs
class ElementIdGenerator {
  static const _uuid = Uuid();

  static String generate() => _uuid.v4();
}
