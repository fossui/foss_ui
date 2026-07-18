part of '../foss_glyph.dart';

/// A calendar page: a bordered body with two top posts and a header rule.
class CalendarGlyph extends FossGlyph {
  /// Creates a calendar glyph in [color].
  const CalendarGlyph(super.color);

  @override
  double get _stroke => 0.08;

  @override
  void _draw(_Pen pen) => pen
    ..path(
      const [(0.16, 0.26), (0.84, 0.26), (0.84, 0.84), (0.16, 0.84)],
      close: true,
    )
    ..line(0.16, 0.42, 0.84, 0.42)
    ..line(0.34, 0.16, 0.34, 0.3)
    ..line(0.66, 0.16, 0.66, 0.3);
}
