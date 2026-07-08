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

  Color lineColor(WidgetTester tester) => tester
      .widget<ColoredBox>(
        find.descendant(
          of: find.byType(FossSeparator),
          matching: find.byType(ColoredBox),
        ),
      )
      .color;

  group('FossSeparator', () {
    testWidgets('horizontal fills width at 1px tall', (tester) async {
      await tester.pumpWidget(
        host(const SizedBox(width: 200, child: FossSeparator())),
      );

      final size = tester.getSize(find.byType(FossSeparator));
      expect(size, const Size(200, 1));
    });

    testWidgets('vertical fills height at 1px wide', (tester) async {
      await tester.pumpWidget(
        host(
          const SizedBox(
            height: 120,
            child: FossSeparator(
              orientation: FossSeparatorOrientation.vertical,
            ),
          ),
        ),
      );

      final size = tester.getSize(find.byType(FossSeparator));
      expect(size, const Size(1, 120));
    });

    testWidgets('paints the border role', (tester) async {
      await tester.pumpWidget(host(const FossSeparator()));
      expect(lineColor(tester), FossThemeData.light.colors.border);
    });

    testWidgets('resolves the dark border role', (tester) async {
      await tester.pumpWidget(
        host(const FossSeparator(), theme: FossThemeData.dark),
      );
      expect(lineColor(tester), FossThemeData.dark.colors.border);
    });

    testWidgets('decorative by default is hidden from semantics', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(host(const FossSeparator()));

      expect(
        find.descendant(
          of: find.byType(FossSeparator),
          matching: find.byType(ExcludeSemantics),
        ),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('decorative false exposes a semantics node', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        host(const FossSeparator(decorative: false)),
      );

      expect(
        find.descendant(
          of: find.byType(FossSeparator),
          matching: find.byType(Semantics),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(FossSeparator),
          matching: find.byType(ExcludeSemantics),
        ),
        findsNothing,
      );
      // A boundary node, not a spoken one: it separates surrounding content but
      // carries no label, since a divider names nothing.
      expect(tester.getSemantics(find.byType(FossSeparator)).label, isEmpty);
      handle.dispose();
    });

    testWidgets('an unbounded long axis surfaces a layout error', (
      tester,
    ) async {
      // A Column hands its child unbounded height, so the vertical rule's
      // infinite extent has nothing to clamp against; Flutter reports it rather
      // than silently misrendering.
      await tester.pumpWidget(
        host(
          const Column(
            children: [
              FossSeparator(orientation: FossSeparatorOrientation.vertical),
            ],
          ),
        ),
      );
      // The invalid constraint throws (cascading into several errors) rather
      // than silently misrendering.
      expect(tester.takeException(), isNotNull);
      // Reset to a valid tree so the broken layout does not re-throw at
      // teardown, then drain the cascade from the invalid constraint.
      await tester.pumpWidget(host(const SizedBox()));
      while (tester.takeException() != null) {
        // drain follow-on layout errors from the same invalid constraint
      }
    });

    testWidgets('stays 1px under 2x text scale', (tester) async {
      await tester.pumpWidget(
        host(
          const SizedBox(width: 200, child: FossSeparator()),
          textScale: 2,
        ),
      );
      expect(tester.getSize(find.byType(FossSeparator)).height, 1);
    });

    testWidgets('is symmetric under RTL', (tester) async {
      await tester.pumpWidget(
        host(
          const SizedBox(width: 200, child: FossSeparator()),
          direction: TextDirection.rtl,
        ),
      );
      expect(tester.getSize(find.byType(FossSeparator)), const Size(200, 1));
    });

    testWidgets('constructs at runtime for each orientation', (tester) async {
      for (final orientation in FossSeparatorOrientation.values) {
        await tester.pumpWidget(
          host(
            SizedBox.square(
              dimension: 20,
              child: FossSeparator(orientation: orientation),
            ),
          ),
        );
        expect(tester.takeException(), isNull);
      }
    });
  });
}
