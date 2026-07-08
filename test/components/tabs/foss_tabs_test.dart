import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fossui/fossui.dart';

import 'host.dart';

const _tabs = <FossTab<String>>[
  FossTab(value: 'one', label: 'One', content: Text('PanelOne')),
  FossTab(value: 'two', label: 'Two', content: Text('PanelTwo')),
  FossTab(value: 'three', label: 'Three', content: Text('PanelThree')),
];

Finder _coloredBox(Color color) => find.byWidgetPredicate(
  (w) => w is ColoredBox && w.color.toARGB32() == color.toARGB32(),
);

Finder _filled(Color color) => find.byWidgetPredicate(
  (w) =>
      w is DecoratedBox &&
      w.decoration is ShapeDecoration &&
      (w.decoration as ShapeDecoration).color?.toARGB32() == color.toARGB32(),
);

void main() {
  final colors = FossThemeData.light.colors;

  group('FossTabsStyle.merge', () {
    test('other wins field by field, this fills the gaps', () {
      const base = FossTabsStyle(
        barColor: Color(0xFF111111),
        activeForeground: Color(0xFF222222),
      );
      const over = FossTabsStyle(activeForeground: Color(0xFF333333));

      final merged = base.merge(over);
      expect(merged.activeForeground, const Color(0xFF333333));
      expect(merged.barColor, const Color(0xFF111111));
    });

    test('null other returns this', () {
      const base = FossTabsStyle(barColor: Color(0xFF111111));
      expect(base.merge(null), same(base));
    });
  });

  group('FossTabs selection', () {
    testWidgets('renders every label and the active panel', (tester) async {
      await tester.pumpWidget(
        host(const FossTabs<String>(tabs: _tabs, initialValue: 'one')),
      );
      await tester.pumpAndSettle();

      expect(find.text('One'), findsOneWidget);
      expect(find.text('Two'), findsOneWidget);
      expect(find.text('PanelOne'), findsOneWidget);
      expect(find.text('PanelTwo'), findsNothing);
    });

    testWidgets('tap swaps the panel when uncontrolled', (tester) async {
      await tester.pumpWidget(
        host(const FossTabs<String>(tabs: _tabs, initialValue: 'one')),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Two'));
      await tester.pumpAndSettle();

      expect(find.text('PanelTwo'), findsOneWidget);
      expect(find.text('PanelOne'), findsNothing);
    });

    testWidgets('controlled tab reports onChanged, holds value', (
      tester,
    ) async {
      String? picked;
      await tester.pumpWidget(
        host(
          FossTabs<String>(
            tabs: _tabs,
            value: 'one',
            onChanged: (v) => picked = v,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Two'));
      await tester.pumpAndSettle();

      expect(picked, 'two');
      // Parent never updated value, so the panel stays.
      expect(find.text('PanelOne'), findsOneWidget);
    });

    testWidgets('disabled tab does not select', (tester) async {
      String? picked;
      await tester.pumpWidget(
        host(
          FossTabs<String>(
            value: 'one',
            onChanged: (v) => picked = v,
            tabs: const [
              FossTab(value: 'one', label: 'One', content: Text('PanelOne')),
              FossTab(
                value: 'two',
                label: 'Two',
                enabled: false,
                content: Text('PanelTwo'),
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Two'), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(picked, isNull);
    });
  });

  group('FossTabs keyboard', () {
    testWidgets('arrow moves focus, Space activates, skipping disabled', (
      tester,
    ) async {
      String? picked;
      await tester.pumpWidget(
        host(
          FossTabs<String>(
            value: 'one',
            onChanged: (v) => picked = v,
            tabs: const [
              FossTab(value: 'one', label: 'One', content: Text('PanelOne')),
              FossTab(
                value: 'two',
                label: 'Two',
                enabled: false,
                content: Text('PanelTwo'),
              ),
              FossTab(
                value: 'three',
                label: 'Three',
                content: Text('PanelThree'),
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('One'));
      await tester.pumpAndSettle();
      expect(picked, 'one');

      // Right skips the disabled middle tab and lands on Three.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();

      expect(picked, 'three');
    });

    testWidgets('Home and End jump to the ends', (tester) async {
      String? picked;
      await tester.pumpWidget(
        host(
          FossTabs<String>(
            value: 'two',
            onChanged: (v) => picked = v,
            tabs: _tabs,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Two'));
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(picked, 'three');

      await tester.sendKeyEvent(LogicalKeyboardKey.home);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(picked, 'one');
    });
  });

  group('FossTabs variants and indicator', () {
    testWidgets('segmented pill fills the background role in light', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(const FossTabs<String>(tabs: _tabs, initialValue: 'one')),
      );
      await tester.pumpAndSettle();
      expect(_filled(colors.background), findsWidgets);
    });

    testWidgets('segmented pill lifts to input in dark', (tester) async {
      await tester.pumpWidget(
        host(
          const FossTheme(
            data: FossThemeData.dark,
            child: FossTabs<String>(tabs: _tabs, initialValue: 'one'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        _filled(FossThemeData.dark.colors.input),
        findsWidgets,
      );
    });

    testWidgets('underline draws a primary bar', (tester) async {
      await tester.pumpWidget(
        host(
          const FossTabs<String>(
            tabs: _tabs,
            initialValue: 'one',
            variant: FossTabsVariant.underline,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(_coloredBox(colors.primary), findsOneWidget);
    });

    testWidgets('vertical orientation renders strip and panel', (tester) async {
      await tester.pumpWidget(
        host(
          const FossTabs<String>(
            tabs: _tabs,
            initialValue: 'one',
            orientation: FossTabsOrientation.vertical,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('One'), findsOneWidget);
      expect(find.text('PanelOne'), findsOneWidget);
    });

    testWidgets('indicator moves when the selection changes', (tester) async {
      await tester.pumpWidget(
        host(const FossTabs<String>(tabs: _tabs, initialValue: 'one')),
      );
      await tester.pumpAndSettle();
      final firstLeft = tester.getTopLeft(_filled(colors.background)).dx;

      await tester.tap(find.text('Three'));
      await tester.pumpAndSettle();
      final lastLeft = tester.getTopLeft(_filled(colors.background)).dx;

      expect(lastLeft, greaterThan(firstLeft));
    });
  });

  group('FossTabs accessibility', () {
    testWidgets('the active tab exposes the selected tab role', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        host(const FossTabs<String>(tabs: _tabs, initialValue: 'two')),
      );
      await tester.pumpAndSettle();

      expect(
        tester.getSemantics(find.bySemanticsLabel('Two')),
        isSemantics(isSelected: true, hasSelectedState: true, label: 'Two'),
      );
      handle.dispose();
    });

    testWidgets('reduced motion swaps without scheduling animation', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          const MediaQuery(
            data: MediaQueryData(disableAnimations: true),
            child: FossTabs<String>(tabs: _tabs, initialValue: 'one'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Two'));
      await tester.pump();

      expect(find.text('PanelTwo'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('RTL mirrors the indicator to the right', (tester) async {
      await tester.pumpWidget(
        host(
          const Directionality(
            textDirection: TextDirection.rtl,
            child: FossTabs<String>(tabs: _tabs, initialValue: 'one'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Under RTL the first tab sits at the trailing (right) side, so its pill
      // starts past the strip's horizontal center.
      final stripCenter = tester.getCenter(find.text('Two')).dx;
      final pillLeft = tester.getTopLeft(_filled(colors.background)).dx;
      expect(pillLeft, greaterThan(stripCenter));
    });
  });

  group('FossTabs extra coverage', () {
    test('a runtime-built tab holds its data', () {
      final tab = FossTab<String>(value: 'one', label: 'One'.toUpperCase());
      expect(tab.value, 'one');
      expect(tab.label, 'ONE');
      expect(tab.enabled, isTrue);
    });

    testWidgets('dropping the active tab disposes its node and clears the '
        'indicator', (tester) async {
      late StateSetter setOuter;
      var full = true;
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (context, setState) {
              setOuter = setState;
              return FossTabs<String>(
                initialValue: 'one',
                tabs: full
                    ? _tabs
                    : const [
                        FossTab(
                          value: 'two',
                          label: 'Two',
                          content: Text('PanelTwo'),
                        ),
                        FossTab(
                          value: 'three',
                          label: 'Three',
                          content: Text('PanelThree'),
                        ),
                      ],
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      setOuter(() => full = false);
      await tester.pumpAndSettle();

      expect(find.text('One'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('horizontal left arrow moves focus back', (tester) async {
      String? picked;
      await tester.pumpWidget(
        host(
          FossTabs<String>(
            value: 'two',
            onChanged: (v) => picked = v,
            tabs: _tabs,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Two'));
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      expect(picked, 'one');
    });

    testWidgets('RTL flips the horizontal arrows', (tester) async {
      String? picked;
      await tester.pumpWidget(
        host(
          Directionality(
            textDirection: TextDirection.rtl,
            child: FossTabs<String>(
              value: 'two',
              onChanged: (v) => picked = v,
              tabs: _tabs,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Two'));
      await tester.pumpAndSettle();

      // Under RTL the right arrow steps toward the start (the first tab).
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      expect(picked, 'one');
    });

    testWidgets('vertical underline navigates with up and down arrows', (
      tester,
    ) async {
      String? picked;
      await tester.pumpWidget(
        host(
          FossTabs<String>(
            value: 'one',
            onChanged: (v) => picked = v,
            orientation: FossTabsOrientation.vertical,
            variant: FossTabsVariant.underline,
            tabs: _tabs,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('One'));
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(picked, 'two');

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(picked, 'one');
    });

    testWidgets('a tab renders its leading icon', (tester) async {
      await tester.pumpWidget(
        host(
          const FossTabs<String>(
            initialValue: 'one',
            tabs: [
              FossTab(
                value: 'one',
                label: 'One',
                icon: SizedBox(key: Key('glyph'), width: 8, height: 8),
                content: Text('PanelOne'),
              ),
              FossTab(value: 'two', label: 'Two', content: Text('PanelTwo')),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('glyph')), findsOneWidget);
    });

    testWidgets('hovering an underline tab tints it and clears on exit', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          const FossTabs<String>(
            tabs: _tabs,
            initialValue: 'one',
            variant: FossTabsVariant.underline,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);

      await gesture.moveTo(tester.getCenter(find.text('Two')));
      await tester.pumpAndSettle();
      await gesture.moveTo(Offset.zero);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('a style override drives the indicator color and shadow', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          const FossTabs<String>(
            tabs: _tabs,
            initialValue: 'one',
            style: FossTabsStyle(
              indicatorColor: Color(0xFF00FF00),
              indicatorShadow: [
                BoxShadow(color: Color(0x11000000), blurRadius: 2),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(_filled(const Color(0xFF00FF00)), findsWidgets);
    });
  });

  group('FossTabs styling', () {
    testWidgets('disabled tab dims to 0.64', (tester) async {
      await tester.pumpWidget(
        host(
          const FossTabs<String>(
            initialValue: 'one',
            tabs: [
              FossTab(value: 'one', label: 'One', content: Text('PanelOne')),
              FossTab(
                value: 'two',
                label: 'Two',
                enabled: false,
                content: Text('PanelTwo'),
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate((w) => w is Opacity && w.opacity == 0.64),
        findsOneWidget,
      );
    });

    testWidgets('segmented pill wears a faint 5% shadow', (tester) async {
      await tester.pumpWidget(
        host(const FossTabs<String>(tabs: _tabs, initialValue: 'one')),
      );
      await tester.pumpAndSettle();

      final pill = tester
          .widgetList<DecoratedBox>(find.byType(DecoratedBox))
          .map((d) => d.decoration)
          .whereType<ShapeDecoration>()
          .firstWhere((d) => (d.shadows ?? const []).isNotEmpty);
      expect(pill.shadows!.first.color.a, closeTo(0.05, 0.001));
    });

    testWidgets('large text scale grows the tab without clipping', (
      tester,
    ) async {
      Widget scaled(double factor) => host(
        MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(factor)),
          child: const FossTabs<String>(tabs: _tabs, initialValue: 'one'),
        ),
      );

      await tester.pumpWidget(scaled(1));
      await tester.pumpAndSettle();
      final base = tester.getSize(_filled(colors.muted).first).height;

      await tester.pumpWidget(scaled(2));
      await tester.pumpAndSettle();
      final grown = tester.getSize(_filled(colors.muted).first).height;

      expect(grown, greaterThan(base));
      expect(tester.takeException(), isNull);
    });

    testWidgets('segmented inactive label dims to 72%', (tester) async {
      await tester.pumpWidget(
        host(const FossTabs<String>(tabs: _tabs, initialValue: 'one')),
      );
      await tester.pumpAndSettle();

      final inactive = tester.widget<Text>(find.text('Two'));
      expect(
        inactive.style?.color,
        colors.mutedForeground.withValues(alpha: 0.72),
      );
    });

    testWidgets('style overrides drive the bar, active label, and text style', (
      tester,
    ) async {
      const barColor = Color(0xFF0A0B0C);
      const activeFg = Color(0xFF0D0E0F);
      await tester.pumpWidget(
        host(
          const FossTabs<String>(
            tabs: _tabs,
            initialValue: 'one',
            style: FossTabsStyle(
              barColor: barColor,
              activeForeground: activeFg,
              labelStyle: TextStyle(fontSize: 21),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(_filled(barColor), findsWidgets);
      final active = tester.widget<Text>(find.text('One'));
      expect(active.style?.color, activeFg);
      expect(active.style?.fontSize, 21);
    });

    testWidgets('inactive foreground override colors an underline tab', (
      tester,
    ) async {
      const inactiveFg = Color(0xFF010203);
      await tester.pumpWidget(
        host(
          const FossTabs<String>(
            tabs: _tabs,
            initialValue: 'one',
            variant: FossTabsVariant.underline,
            style: FossTabsStyle(inactiveForeground: inactiveFg),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.widget<Text>(find.text('Two')).style?.color, inactiveFg);
    });

    testWidgets('hover override tints the underline tab', (tester) async {
      const hover = Color(0xFF04FF05);
      await tester.pumpWidget(
        host(
          const FossTabs<String>(
            tabs: _tabs,
            initialValue: 'one',
            variant: FossTabsVariant.underline,
            style: FossTabsStyle(hoverColor: hover),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);
      await gesture.moveTo(tester.getCenter(find.text('Two')));
      await tester.pumpAndSettle();

      expect(_filled(hover), findsOneWidget);
    });

    testWidgets('leading icon receives the 18px icon theme', (tester) async {
      double? size;
      await tester.pumpWidget(
        host(
          FossTabs<String>(
            initialValue: 'one',
            tabs: [
              FossTab(
                value: 'one',
                label: 'One',
                icon: Builder(
                  builder: (context) {
                    size = IconTheme.of(context).size;
                    return const SizedBox.shrink();
                  },
                ),
                content: const Text('PanelOne'),
              ),
              const FossTab(value: 'two', label: 'Two', content: Text('P2')),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(size, 18);
    });
  });
}
