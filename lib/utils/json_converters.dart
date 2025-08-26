import 'dart:ui';
import 'package:flutter/painting.dart';
import 'package:json_annotation/json_annotation.dart';

/// JSON converter for Flutter's Offset class
class OffsetConverter implements JsonConverter<Offset, Map<String, dynamic>> {
  const OffsetConverter();

  @override
  Offset fromJson(Map<String, dynamic> json) {
    return Offset(
      (json['dx'] as num).toDouble(),
      (json['dy'] as num).toDouble(),
    );
  }

  @override
  Map<String, dynamic> toJson(Offset offset) {
    return {
      'dx': offset.dx,
      'dy': offset.dy,
    };
  }
}

/// JSON converter for Flutter's Size class
class SizeConverter implements JsonConverter<Size, Map<String, dynamic>> {
  const SizeConverter();

  @override
  Size fromJson(Map<String, dynamic> json) {
    return Size(
      (json['width'] as num).toDouble(),
      (json['height'] as num).toDouble(),
    );
  }

  @override
  Map<String, dynamic> toJson(Size size) {
    return {
      'width': size.width,
      'height': size.height,
    };
  }
}

/// JSON converter for Flutter's Color class
class ColorConverter implements JsonConverter<Color, int> {
  const ColorConverter();

  @override
  Color fromJson(int json) {
    return Color(json);
  }

  @override
  int toJson(Color color) {
    return color.value;
  }
}

/// JSON converter for nullable Color
class NullableColorConverter implements JsonConverter<Color?, int?> {
  const NullableColorConverter();

  @override
  Color? fromJson(int? json) {
    return json != null ? Color(json) : null;
  }

  @override
  int? toJson(Color? color) {
    return color?.value;
  }
}

/// JSON converter for FontWeight
class FontWeightConverter implements JsonConverter<FontWeight, int> {
  const FontWeightConverter();

  @override
  FontWeight fromJson(int json) {
    switch (json) {
      case 100:
        return FontWeight.w100;
      case 200:
        return FontWeight.w200;
      case 300:
        return FontWeight.w300;
      case 400:
        return FontWeight.w400;
      case 500:
        return FontWeight.w500;
      case 600:
        return FontWeight.w600;
      case 700:
        return FontWeight.w700;
      case 800:
        return FontWeight.w800;
      case 900:
        return FontWeight.w900;
      default:
        return FontWeight.normal;
    }
  }

  @override
  int toJson(FontWeight fontWeight) {
    return fontWeight.index * 100 + 100;
  }
}

/// JSON converter for FontStyle
class FontStyleConverter implements JsonConverter<FontStyle, String> {
  const FontStyleConverter();

  @override
  FontStyle fromJson(String json) {
    switch (json) {
      case 'italic':
        return FontStyle.italic;
      case 'normal':
      default:
        return FontStyle.normal;
    }
  }

  @override
  String toJson(FontStyle fontStyle) {
    return fontStyle == FontStyle.italic ? 'italic' : 'normal';
  }
}

/// JSON converter for TextAlign
class TextAlignConverter implements JsonConverter<TextAlign, String> {
  const TextAlignConverter();

  @override
  TextAlign fromJson(String json) {
    switch (json) {
      case 'left':
        return TextAlign.left;
      case 'center':
        return TextAlign.center;
      case 'right':
        return TextAlign.right;
      case 'justify':
        return TextAlign.justify;
      case 'start':
        return TextAlign.start;
      case 'end':
        return TextAlign.end;
      default:
        return TextAlign.left;
    }
  }

  @override
  String toJson(TextAlign textAlign) {
    switch (textAlign) {
      case TextAlign.left:
        return 'left';
      case TextAlign.center:
        return 'center';
      case TextAlign.right:
        return 'right';
      case TextAlign.justify:
        return 'justify';
      case TextAlign.start:
        return 'start';
      case TextAlign.end:
        return 'end';
    }
  }
}

/// JSON converter for TextDecoration
class TextDecorationConverter implements JsonConverter<TextDecoration, String> {
  const TextDecorationConverter();

  @override
  TextDecoration fromJson(String json) {
    switch (json) {
      case 'underline':
        return TextDecoration.underline;
      case 'overline':
        return TextDecoration.overline;
      case 'lineThrough':
        return TextDecoration.lineThrough;
      case 'none':
      default:
        return TextDecoration.none;
    }
  }

  @override
  String toJson(TextDecoration textDecoration) {
    if (textDecoration == TextDecoration.underline) {
      return 'underline';
    } else if (textDecoration == TextDecoration.overline) {
      return 'overline';
    } else if (textDecoration == TextDecoration.lineThrough) {
      return 'lineThrough';
    } else {
      return 'none';
    }
  }
}

/// JSON converter for BoxFit
class BoxFitConverter implements JsonConverter<BoxFit, String> {
  const BoxFitConverter();

  @override
  BoxFit fromJson(String json) {
    switch (json) {
      case 'fill':
        return BoxFit.fill;
      case 'contain':
        return BoxFit.contain;
      case 'cover':
        return BoxFit.cover;
      case 'fitWidth':
        return BoxFit.fitWidth;
      case 'fitHeight':
        return BoxFit.fitHeight;
      case 'none':
        return BoxFit.none;
      case 'scaleDown':
        return BoxFit.scaleDown;
      default:
        return BoxFit.cover;
    }
  }

  @override
  String toJson(BoxFit boxFit) {
    switch (boxFit) {
      case BoxFit.fill:
        return 'fill';
      case BoxFit.contain:
        return 'contain';
      case BoxFit.cover:
        return 'cover';
      case BoxFit.fitWidth:
        return 'fitWidth';
      case BoxFit.fitHeight:
        return 'fitHeight';
      case BoxFit.none:
        return 'none';
      case BoxFit.scaleDown:
        return 'scaleDown';
    }
  }
}

/// JSON converter for StrokeCap
class StrokeCapConverter implements JsonConverter<StrokeCap, String> {
  const StrokeCapConverter();

  @override
  StrokeCap fromJson(String json) {
    switch (json) {
      case 'butt':
        return StrokeCap.butt;
      case 'round':
        return StrokeCap.round;
      case 'square':
        return StrokeCap.square;
      default:
        return StrokeCap.round;
    }
  }

  @override
  String toJson(StrokeCap strokeCap) {
    switch (strokeCap) {
      case StrokeCap.butt:
        return 'butt';
      case StrokeCap.round:
        return 'round';
      case StrokeCap.square:
        return 'square';
    }
  }
}
