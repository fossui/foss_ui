part of 'foss_tabs.dart';

/// Builds the default appearance from the theme tokens for [variant], then lays
/// a per-instance [override] over it field by field.
_TabsVisuals _resolve(
  FossThemeData theme,
  FossTabsVariant variant,
  bool dark,
  FossTabsStyle? override,
) {
  final c = theme.colors;
  final segmented = variant == FossTabsVariant.segmented;
  return _TabsVisuals(
    barColor: override?.barColor ?? c.muted,
    indicatorColor:
        override?.indicatorColor ??
        (segmented ? (dark ? c.input : c.background) : c.primary),
    indicatorShadow:
        override?.indicatorShadow ??
        (segmented ? _pillShadow(theme.shadows.sm) : const <BoxShadow>[]),
    hoverColor: override?.hoverColor ?? c.accent,
    activeForeground: override?.activeForeground ?? c.foreground,
    inactiveForeground: override?.inactiveForeground ?? c.mutedForeground,
    labelStyle: override?.labelStyle ?? theme.typography.base.medium,
    barRadius: theme.radii.lg,
    tabRadius: theme.radii.md,
  );
}

// The elevated pill wears a faint lift, the small shadow softened to a 5% tint
// so it reads as a whisper of elevation, not a drop shadow.
List<BoxShadow> _pillShadow(List<BoxShadow> base) => <BoxShadow>[
  for (final shadow in base)
    shadow.copyWith(color: shadow.color.withValues(alpha: 0.05)),
];

/// The fully resolved, non-null appearance. A [FossTabsStyle] override is laid
/// over it by [_resolve], so the widget reads only non-null fields.
@immutable
class _TabsVisuals {
  const _TabsVisuals({
    required this.barColor,
    required this.indicatorColor,
    required this.indicatorShadow,
    required this.hoverColor,
    required this.activeForeground,
    required this.inactiveForeground,
    required this.labelStyle,
    required this.barRadius,
    required this.tabRadius,
  });

  final Color barColor;
  final Color indicatorColor;
  final List<BoxShadow> indicatorShadow;
  final Color hoverColor;
  final Color activeForeground;
  final Color inactiveForeground;
  final TextStyle labelStyle;
  final double barRadius;
  final double tabRadius;
}
