part of 'foss_text_field.dart';

/// Visual overrides for a [FossTextField]. Every field is optional; a null
/// field falls back to the value the theme resolves for the size and state.
/// Pass one to a single field via `style:` to tweak a one-off, without changing
/// the theme for every other field.
///
/// State-derived colors (the focus ring and error border) stay token-driven.
/// To restyle those globally, retheme `FossColors`.
///
/// A wider, pill-cornered field with a custom resting border:
///
/// ```dart
/// FossTextField(
///   label: 'Email',
///   style: const FossTextFieldStyle(
///     borderRadius: 999,
///     borderColor: Color(0xFFD4D4D4),
///     contentPadding: EdgeInsets.symmetric(horizontal: 16),
///   ),
/// );
/// ```
@immutable
class FossTextFieldStyle {
  /// Creates a set of field overrides. All fields default to null (inherit).
  const FossTextFieldStyle({
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
    this.contentPadding,
    this.minHeight,
    this.textStyle,
    this.labelStyle,
    this.helperStyle,
    this.iconSize,
    this.gap,
    this.shadow,
  });

  /// Fill color of the field box.
  final Color? backgroundColor;

  /// Resting border color, used when the field is neither focused nor invalid.
  final Color? borderColor;

  /// Corner radius in logical pixels.
  final double? borderRadius;

  /// Inner padding around the editable content.
  final EdgeInsetsGeometry? contentPadding;

  /// Minimum box height in logical pixels; grows with text scale.
  final double? minHeight;

  /// Style of the editable value and placeholder.
  final TextStyle? textStyle;

  /// Style of the [FossTextField.label] above the box.
  final TextStyle? labelStyle;

  /// Style of the helper and error caption below the box.
  final TextStyle? helperStyle;

  /// Leading and trailing icon size in logical pixels.
  final double? iconSize;

  /// Gap between an affix and the editable content in logical pixels.
  final double? gap;

  /// Drop shadow layers at rest; empty for none.
  final List<BoxShadow>? shadow;

  /// Returns a copy with every non-null field of [other] laid over this one.
  ///
  /// ```dart
  /// const base = FossTextFieldStyle(borderRadius: 8, minHeight: 34);
  /// const override = FossTextFieldStyle(minHeight: 30);
  /// base.merge(override); // borderRadius 8 kept, minHeight becomes 30
  /// ```
  FossTextFieldStyle merge(FossTextFieldStyle? other) {
    if (other == null) return this;
    return FossTextFieldStyle(
      backgroundColor: other.backgroundColor ?? backgroundColor,
      borderColor: other.borderColor ?? borderColor,
      borderRadius: other.borderRadius ?? borderRadius,
      contentPadding: other.contentPadding ?? contentPadding,
      minHeight: other.minHeight ?? minHeight,
      textStyle: other.textStyle ?? textStyle,
      labelStyle: other.labelStyle ?? labelStyle,
      helperStyle: other.helperStyle ?? helperStyle,
      iconSize: other.iconSize ?? iconSize,
      gap: other.gap ?? gap,
      shadow: other.shadow ?? shadow,
    );
  }
}
