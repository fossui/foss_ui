import 'package:flutter/material.dart' show ThemeExtension;
import 'package:flutter/widgets.dart';
import 'package:fossui/src/theme/lerp_encoders.dart';
import 'package:theme_tailor_annotation/theme_tailor_annotation.dart';

part 'foss_shadows.tailor.dart';

/// Layered drop shadows per elevation step. Each is a baked `List<BoxShadow>`
/// (black at low alpha); [none] is an empty list. Resolved at author time, no
/// shadow math at runtime.
///
/// ```dart
/// const s = FossShadows.standard;
/// DecoratedBox(decoration: BoxDecoration(boxShadow: s.md));
/// ```
@TailorMixin(
  themeGetter: ThemeGetter.none,
  encoders: [BoxShadowListLerpEncoder()],
)
class FossShadows extends ThemeExtension<FossShadows>
    with _$FossShadowsTailorMixin {
  /// Creates a shadow scale. Prefer [standard] unless retheming.
  const FossShadows({
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
  });

  /// Subtle lift: controls, chips.
  @override
  final List<BoxShadow> xs;

  /// Small elevation: raised buttons.
  @override
  final List<BoxShadow> sm;

  /// Medium elevation: cards.
  @override
  final List<BoxShadow> md;

  /// Large elevation: popovers, sheets, dialogs.
  @override
  final List<BoxShadow> lg;

  /// No shadow.
  static const none = <BoxShadow>[];

  /// The default shadow scale.
  static const standard = FossShadows(
    xs: [
      BoxShadow(color: Color(0x0D000000), offset: Offset(0, 1), blurRadius: 2),
    ],
    sm: [
      BoxShadow(color: Color(0x0F000000), offset: Offset(0, 1), blurRadius: 2),
      BoxShadow(color: Color(0x1A000000), offset: Offset(0, 1), blurRadius: 3),
    ],
    md: [
      BoxShadow(
        color: Color(0x0F000000),
        offset: Offset(0, 2),
        blurRadius: 4,
        spreadRadius: -1,
      ),
      BoxShadow(
        color: Color(0x1A000000),
        offset: Offset(0, 4),
        blurRadius: 6,
        spreadRadius: -1,
      ),
    ],
    lg: [
      BoxShadow(
        color: Color(0x0D000000),
        offset: Offset(0, 4),
        blurRadius: 6,
        spreadRadius: -2,
      ),
      BoxShadow(
        color: Color(0x1A000000),
        offset: Offset(0, 10),
        blurRadius: 15,
        spreadRadius: -3,
      ),
    ],
  );
}
