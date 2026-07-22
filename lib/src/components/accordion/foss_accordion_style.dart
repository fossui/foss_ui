part of 'foss_accordion.dart';

/// Visual overrides for a single accordion. Every field is optional; a null
/// field falls back to the value the theme resolves. Pass one via `style:` to
/// tweak a one-off without changing the theme for every other accordion.
///
/// The focus ring stays token-driven (the `ring` role); to restyle it globally,
/// retheme [FossColors].
///
/// A quieter divider and a larger title:
///
/// ```dart
/// FossAccordion(
///   style: FossAccordionStyle(
///     dividerColor: Color(0x11000000),
///     titleTextStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
///   ),
///   children: const [
///     FossAccordionItem(value: 'a', title: Text('T'), child: Text('Body')),
///   ],
/// );
/// ```
@FossSince('0.1.1')
@immutable
class FossAccordionStyle {
  /// Creates a set of accordion overrides. Fields default to null (inherit).
  const FossAccordionStyle({
    this.titleTextStyle,
    this.panelTextStyle,
    this.chevronColor,
    this.dividerColor,
    this.headerPadding,
    this.panelPadding,
  });

  /// Text style of the header title.
  final TextStyle? titleTextStyle;

  /// Text style of the panel content.
  final TextStyle? panelTextStyle;

  /// Color of the header chevron.
  final Color? chevronColor;

  /// Color of the 1px hairline under each item (dropped on the last item).
  final Color? dividerColor;

  /// Padding around the header row.
  final EdgeInsetsGeometry? headerPadding;

  /// Padding around the panel content.
  final EdgeInsetsGeometry? panelPadding;

  /// Returns a copy with every non-null field of [other] laid over this one.
  ///
  /// ```dart
  /// const base = FossAccordionStyle(dividerColor: Color(0x14000000));
  /// const override = FossAccordionStyle(dividerColor: Color(0x11000000));
  /// base.merge(override); // dividerColor becomes 0x11000000
  /// ```
  FossAccordionStyle merge(FossAccordionStyle? other) {
    if (other == null) return this;
    return FossAccordionStyle(
      titleTextStyle: other.titleTextStyle ?? titleTextStyle,
      panelTextStyle: other.panelTextStyle ?? panelTextStyle,
      chevronColor: other.chevronColor ?? chevronColor,
      dividerColor: other.dividerColor ?? dividerColor,
      headerPadding: other.headerPadding ?? headerPadding,
      panelPadding: other.panelPadding ?? panelPadding,
    );
  }
}
