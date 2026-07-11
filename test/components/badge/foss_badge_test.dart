import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fossui/fossui.dart';

void main() {
  Widget host(
    Widget child, {
    FossThemeData? theme,
    TextDirection direction = TextDirection.ltr,
    double textScale = 1,
  }) => FossTheme(
    data: theme ?? FossThemeData.light,
    child: Directionality(
      textDirection: direction,
      child: MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
        child: Align(alignment: Alignment.topLeft, child: child),
      ),
    ),
  );

  ShapeDecoration pillDecoration(WidgetTester tester) {
    final box = find.descendant(
      of: find.byType(FossBadge),
      matching: find.byType(DecoratedBox),
    );
    return tester.widget<DecoratedBox>(box.first).decoration as ShapeDecoration;
  }

  RoundedSuperellipseBorder pillShape(WidgetTester tester) =>
      pillDecoration(tester).shape as RoundedSuperellipseBorder;

  TextStyle labelStyle(WidgetTester tester) {
    final styles = find.descendant(
      of: find.byType(FossBadge),
      matching: find.byType(DefaultTextStyle),
    );
    return tester.widget<DefaultTextStyle>(styles.first).style;
  }

  group('FossBadgeStyle.merge', () {
    test('lays every non-null field of other over this', () {
      const base = FossBadgeStyle(
        backgroundColor: Color(0xFF111111),
        borderColor: Color(0xFF222222),
        foregroundColor: Color(0xFF333333),
        borderRadius: 4,
        labelStyle: TextStyle(fontSize: 9),
      );
      const over = FossBadgeStyle(
        foregroundColor: Color(0xFF444444),
        borderRadius: 12,
      );

      final merged = base.merge(over);

      expect(merged.backgroundColor, const Color(0xFF111111));
      expect(merged.borderColor, const Color(0xFF222222));
      expect(merged.foregroundColor, const Color(0xFF444444));
      expect(merged.borderRadius, 12);
      expect(merged.labelStyle, const TextStyle(fontSize: 9));
    });

    test('null other returns this unchanged', () {
      const base = FossBadgeStyle(backgroundColor: Color(0xFF111111));
      expect(identical(base.merge(null), base), isTrue);
    });
  });

  group('variant colors', () {
    Future<void> pump(
      WidgetTester tester,
      FossBadgeVariant variant, {
      FossThemeData? theme,
    }) => tester.pumpWidget(
      host(
        FossBadge(label: const Text('x'), variant: variant),
        theme: theme,
      ),
    );

    testWidgets('primary fills primary with its foreground', (tester) async {
      const c = FossColors.light;
      await pump(tester, FossBadgeVariant.primary);
      expect(pillDecoration(tester).color, c.primary);
      expect(labelStyle(tester).color, c.primaryForeground);
    });

    testWidgets('secondary fills secondary', (tester) async {
      const c = FossColors.light;
      await pump(tester, FossBadgeVariant.secondary);
      expect(pillDecoration(tester).color, c.secondary);
      expect(labelStyle(tester).color, c.secondaryForeground);
    });

    testWidgets('outline is background with a border', (tester) async {
      const c = FossColors.light;
      await pump(tester, FossBadgeVariant.outline);
      expect(pillDecoration(tester).color, c.background);
      expect(pillShape(tester).side.color, c.border);
      expect(labelStyle(tester).color, c.foreground);
    });

    testWidgets('destructive is solid with the on-fill foreground', (
      tester,
    ) async {
      const c = FossColors.light;
      await pump(tester, FossBadgeVariant.destructive);
      expect(pillDecoration(tester).color, c.destructive);
      expect(labelStyle(tester).color, c.destructiveForegroundOn);
    });

    testWidgets('solid variants draw no border', (tester) async {
      await pump(tester, FossBadgeVariant.primary);
      expect(pillShape(tester).side, BorderSide.none);
    });

    testWidgets('soft info tints info at 8% in light', (tester) async {
      const c = FossColors.light;
      await pump(tester, FossBadgeVariant.info);
      expect(
        pillDecoration(tester).color,
        c.info.withValues(alpha: c.info.a * 0.08),
      );
      expect(labelStyle(tester).color, c.infoForeground);
    });

    testWidgets('soft info tints info at 16% in dark', (tester) async {
      const c = FossColors.dark;
      await pump(tester, FossBadgeVariant.info, theme: FossThemeData.dark);
      expect(
        pillDecoration(tester).color,
        c.info.withValues(alpha: c.info.a * 0.16),
      );
      expect(labelStyle(tester).color, c.infoForeground);
    });

    testWidgets('error tints destructive but uses its paired foreground', (
      tester,
    ) async {
      const c = FossColors.light;
      await pump(tester, FossBadgeVariant.error);
      expect(
        pillDecoration(tester).color,
        c.destructive.withValues(alpha: c.destructive.a * 0.08),
      );
      expect(labelStyle(tester).color, c.destructiveForeground);
    });

    testWidgets('success and warning tint their roles', (tester) async {
      const c = FossColors.light;
      await pump(tester, FossBadgeVariant.success);
      expect(
        pillDecoration(tester).color,
        c.success.withValues(alpha: c.success.a * 0.08),
      );
      await pump(tester, FossBadgeVariant.warning);
      expect(
        pillDecoration(tester).color,
        c.warning.withValues(alpha: c.warning.a * 0.08),
      );
    });
  });

  group('sizes', () {
    Future<void> pump(WidgetTester tester, FossBadgeSize size) =>
        tester.pumpWidget(
          host(FossBadge(label: const Text('x'), size: size)),
        );

    double minWidth(WidgetTester tester) => tester
        .widget<ConstrainedBox>(
          find.descendant(
            of: find.byType(FossBadge),
            matching: find.byType(ConstrainedBox),
          ),
        )
        .constraints
        .minWidth;

    double padding(WidgetTester tester) =>
        (tester
                    .widget<Padding>(
                      find.descendant(
                        of: find.byType(FossBadge),
                        matching: find.byType(Padding),
                      ),
                    )
                    .padding
                as EdgeInsets)
            .left;

    testWidgets('sm: height 20, padding 4, xs type, radius 4', (tester) async {
      await pump(tester, FossBadgeSize.sm);
      expect(minWidth(tester), 20);
      expect(padding(tester), 4);
      expect(labelStyle(tester).fontSize, FossTypography.standard.xs.fontSize);
      expect(
        pillShape(tester).borderRadius.resolve(TextDirection.ltr).topLeft.x,
        4,
      );
    });

    testWidgets('md: height 22, padding 4, sm type, radii.sm', (tester) async {
      await pump(tester, FossBadgeSize.md);
      expect(minWidth(tester), 22);
      expect(padding(tester), 4);
      expect(labelStyle(tester).fontSize, FossTypography.standard.sm.fontSize);
      expect(
        pillShape(tester).borderRadius.resolve(TextDirection.ltr).topLeft.x,
        FossRadii.standard.sm,
      );
    });

    testWidgets('lg: height 26, padding 6, base type, radii.sm', (
      tester,
    ) async {
      await pump(tester, FossBadgeSize.lg);
      expect(minWidth(tester), 26);
      expect(padding(tester), 6);
      expect(
        labelStyle(tester).fontSize,
        FossTypography.standard.base.fontSize,
      );
      expect(
        pillShape(tester).borderRadius.resolve(TextDirection.ltr).topLeft.x,
        FossRadii.standard.sm,
      );
    });
  });

  group('slots', () {
    testWidgets('renders leading, label, and trailing', (tester) async {
      await tester.pumpWidget(
        host(
          const FossBadge(
            label: Text('Tag'),
            leading: Text('L'),
            trailing: Text('T'),
          ),
        ),
      );
      expect(find.text('L'), findsOneWidget);
      expect(find.text('Tag'), findsOneWidget);
      expect(find.text('T'), findsOneWidget);
    });

    testWidgets('label-only renders without icon slots', (tester) async {
      await tester.pumpWidget(host(const FossBadge(label: Text('Tag'))));
      expect(find.text('Tag'), findsOneWidget);
      expect(find.byType(IconTheme), findsNothing);
    });

    testWidgets('icon slots are sized to 14 and dimmed', (tester) async {
      await tester.pumpWidget(
        host(const FossBadge(label: Text('Tag'), leading: Text('L'))),
      );
      final iconTheme = tester.widget<IconTheme>(
        find.descendant(
          of: find.byType(FossBadge),
          matching: find.byType(IconTheme),
        ),
      );
      expect(iconTheme.data.size, 14);
      final opacity = tester.widget<Opacity>(
        find.descendant(
          of: find.byType(FossBadge),
          matching: find.byType(Opacity),
        ),
      );
      expect(opacity.opacity, 0.8);
    });
  });

  group('accessibility', () {
    testWidgets('label reads in place without a semantics wrapper', (
      tester,
    ) async {
      await tester.pumpWidget(host(const FossBadge(label: Text('New'))));
      expect(
        find.descendant(
          of: find.byType(FossBadge),
          matching: find.byType(ExcludeSemantics),
        ),
        findsNothing,
      );
    });

    testWidgets('semanticLabel replaces the read-in-place content', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        host(
          const FossBadge(label: Text('3'), semanticLabel: '3 unread'),
        ),
      );
      expect(
        find.bySemanticsLabel('3 unread'),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('grows with textScale and mirrors under RTL', (tester) async {
      await tester.pumpWidget(
        host(
          const FossBadge(label: Text('Tag'), leading: Text('L')),
          direction: TextDirection.rtl,
          textScale: 2,
        ),
      );
      expect(tester.takeException(), isNull);
      final size = tester.getSize(find.byType(FossBadge));
      expect(size.height, greaterThan(22));
    });
  });

  group('style', () {
    testWidgets('overrides win over the variant', (tester) async {
      await tester.pumpWidget(
        host(
          const FossBadge(
            label: Text('x'),
            style: FossBadgeStyle(
              backgroundColor: Color(0xFF010203),
              foregroundColor: Color(0xFF040506),
            ),
          ),
        ),
      );
      expect(pillDecoration(tester).color, const Color(0xFF010203));
      expect(labelStyle(tester).color, const Color(0xFF040506));
    });

    testWidgets('border, radius, and label style reach the pill', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          const FossBadge(
            label: Text('x'),
            style: FossBadgeStyle(
              borderColor: Color(0xFF0A0B0C),
              borderRadius: 9,
              labelStyle: TextStyle(fontSize: 21),
            ),
          ),
        ),
      );
      final shape = pillShape(tester);
      expect(shape.side.color, const Color(0xFF0A0B0C));
      expect((shape.borderRadius as BorderRadius).topLeft.x, 9);
      expect(labelStyle(tester).fontSize, 21);
    });
  });

  group('dark', () {
    testWidgets('outline lifts its fill with the input color', (tester) async {
      await tester.pumpWidget(
        host(
          const FossBadge(
            label: Text('x'),
            variant: FossBadgeVariant.outline,
          ),
          theme: FossThemeData.dark,
        ),
      );
      final c = FossThemeData.dark.colors;
      expect(
        pillDecoration(tester).color,
        Color.alphaBlend(
          c.input.withValues(alpha: c.input.a * 0.32),
          c.background,
        ),
      );
    });

    testWidgets('a solid variant keeps its role fill', (tester) async {
      await tester.pumpWidget(
        host(const FossBadge(label: Text('x')), theme: FossThemeData.dark),
      );
      expect(pillDecoration(tester).color, FossThemeData.dark.colors.primary);
    });
  });

  group('slots and geometry', () {
    testWidgets('the trailing slot is themed and dimmed like the leading', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          const FossBadge(
            label: Text('x'),
            leading: Text('L'),
            trailing: Text('T'),
          ),
        ),
      );
      final themed = tester
          .widgetList<IconTheme>(
            find.descendant(
              of: find.byType(FossBadge),
              matching: find.byType(IconTheme),
            ),
          )
          .where((t) => t.data.size == 14);
      expect(themed.length, 2);
      final dimmed = tester
          .widgetList<Opacity>(
            find.descendant(
              of: find.byType(FossBadge),
              matching: find.byType(Opacity),
            ),
          )
          .where((o) => o.opacity == 0.8);
      expect(dimmed.length, 2);
    });

    testWidgets('icon slots are excluded from semantics', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        host(const FossBadge(label: Text('Tag'), leading: Text('ICON'))),
      );
      expect(find.bySemanticsLabel('ICON'), findsNothing);
      expect(find.bySemanticsLabel('Tag'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('a single-glyph badge hugs a square pill', (tester) async {
      await tester.pumpWidget(host(const FossBadge(label: Text('1'))));
      expect(tester.getSize(find.byType(FossBadge)), const Size(22, 22));
    });
  });
}
