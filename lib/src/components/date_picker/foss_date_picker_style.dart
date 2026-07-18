part of 'foss_date_picker.dart';

/// Visual overrides for a single [FossDatePicker]. Every field is optional; a
/// null field falls back to the value the theme resolves. Pass one via `style:`
/// to tweak a one-off without retheming.
///
/// It carries only the date picker's own trigger knobs. The trigger chrome,
/// the dialog surface, and the embedded calendar restyle through the theme or
/// their own styles, not through here.
///
/// ```dart
/// FossDatePicker.single(
///   selected: picked,
///   onSelected: (day) => setState(() => picked = day),
///   style: const FossDatePickerStyle(gap: 8),
/// );
/// ```
@FossSince('0.1.1')
@immutable
class FossDatePickerStyle {
  /// Creates a set of trigger overrides. All fields default to null (inherit).
  const FossDatePickerStyle({this.placeholderColor, this.gap});

  /// Color of the placeholder label shown while nothing is selected.
  final Color? placeholderColor;

  /// Gap between the leading calendar glyph and the label, in logical pixels.
  final double? gap;

  /// Returns a copy with every non-null field of [other] laid over this one.
  FossDatePickerStyle merge(FossDatePickerStyle? other) {
    if (other == null) return this;
    return FossDatePickerStyle(
      placeholderColor: other.placeholderColor ?? placeholderColor,
      gap: other.gap ?? gap,
    );
  }
}
