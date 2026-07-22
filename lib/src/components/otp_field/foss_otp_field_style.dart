part of 'foss_otp_field.dart';

/// Visual overrides for a [FossOtpField]. Every field is optional; a null field
/// falls back to the value the theme resolves for the size and state. Pass one
/// via `style:` to tweak a single field without retheming every other one.
///
/// State-derived colors (the focus ring and error border) stay token-driven. To
/// restyle those globally, retheme `FossColors`.
///
/// Wider slots with a custom resting border and no shadow:
///
/// ```dart
/// FossOtpField(
///   length: 6,
///   style: const FossOtpFieldStyle(
///     slotSize: 48,
///     borderColor: Color(0xFFD4D4D4),
///     shadow: [],
///   ),
/// );
/// ```
@immutable
class FossOtpFieldStyle {
  /// Creates a set of slot overrides. All fields default to null (inherit).
  const FossOtpFieldStyle({
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
    this.slotSize,
    this.textStyle,
    this.gap,
    this.shadow,
    this.separatorColor,
    this.separatorSize,
  });

  /// Fill color of each slot.
  final Color? backgroundColor;

  /// Resting border color, used when the slot is neither active nor invalid.
  final Color? borderColor;

  /// Corner radius of each slot in logical pixels.
  final double? borderRadius;

  /// Edge length of each square slot in logical pixels, before text scaling.
  final double? slotSize;

  /// Style of the slot character. Its color is ignored; the character color
  /// stays token-driven.
  final TextStyle? textStyle;

  /// Gap between slots and around a group separator in logical pixels.
  final double? gap;

  /// Drop shadow layers at rest; empty for none.
  final List<BoxShadow>? shadow;

  /// Color of the group separator pill.
  final Color? separatorColor;

  /// Size of the group separator pill in logical pixels, before text scaling.
  final Size? separatorSize;

  /// Returns a copy with every non-null field of [other] laid over this one.
  ///
  /// ```dart
  /// const base = FossOtpFieldStyle(slotSize: 36, gap: 8);
  /// const override = FossOtpFieldStyle(slotSize: 44);
  /// base.merge(override); // slotSize 44, gap 8 kept
  /// ```
  FossOtpFieldStyle merge(FossOtpFieldStyle? other) {
    if (other == null) return this;
    return FossOtpFieldStyle(
      backgroundColor: other.backgroundColor ?? backgroundColor,
      borderColor: other.borderColor ?? borderColor,
      borderRadius: other.borderRadius ?? borderRadius,
      slotSize: other.slotSize ?? slotSize,
      textStyle: other.textStyle ?? textStyle,
      gap: other.gap ?? gap,
      shadow: other.shadow ?? shadow,
      separatorColor: other.separatorColor ?? separatorColor,
      separatorSize: other.separatorSize ?? separatorSize,
    );
  }
}

/// The fully resolved, non-null slot appearance for one size. A
/// [FossOtpFieldStyle] override is laid over it by [_apply], so the widget
/// reads only non-null fields and never needs the null-assertion operator.
@immutable
class _OtpVisuals {
  const _OtpVisuals({
    required this.background,
    required this.borderColor,
    required this.textColor,
    required this.borderRadius,
    required this.slotSize,
    required this.textStyle,
    required this.gap,
    required this.shadow,
    required this.separatorColor,
    required this.separatorSize,
  });

  final Color background;
  final Color borderColor;
  final Color textColor;
  final double borderRadius;
  final double slotSize;
  final TextStyle textStyle;
  final double gap;
  final List<BoxShadow> shadow;
  final Color separatorColor;
  final Size separatorSize;
}
