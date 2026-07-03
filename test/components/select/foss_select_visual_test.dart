import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fossui/fossui.dart';

import 'host.dart';

const List<FossSelectItem<String>> _items = [
  FossSelectItem(value: 'a', label: 'Apple'),
  FossSelectItem(value: 'b', label: 'Banana'),
];

Iterable<ShapeDecoration> _shapeDecorations(WidgetTester tester) => tester
    .widgetList<DecoratedBox>(find.byType(DecoratedBox))
    .map((d) => d.decoration)
    .whereType<ShapeDecoration>();

void main() {
  group('FossSelect visuals', () {
    testWidgets('the dark trigger fill lifts off the surface', (tester) async {
      await tester.pumpWidget(
        host(
          theme: FossThemeData.dark,
          const FossSelect<String>(placeholder: 'Pick', items: _items),
        ),
      );

      final surface = FossThemeData.dark.colors.background;
      expect(
        _shapeDecorations(
          tester,
        ).any((d) => d.color != null && d.color != surface),
        isTrue,
        reason: 'trigger fill is lifted, not the bare dark surface',
      );
    });

    testWidgets('errorText recolors the trigger border to destructive', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          const FossSelect<String>(
            placeholder: 'Pick',
            errorText: 'Required',
            items: _items,
          ),
        ),
      );

      final expected = FossThemeData.light.colors.destructive.withValues(
        alpha: 0.36,
      );
      final borders = _shapeDecorations(tester)
          .map((d) => d.shape)
          .whereType<RoundedSuperellipseBorder>()
          .map((b) => b.side.color);
      expect(borders, contains(expected));
    });

    testWidgets('a full style override recolors the trigger', (tester) async {
      const background = Color(0xFF102030);
      const border = Color(0xFF405060);
      const style = FossSelectStyle(
        backgroundColor: background,
        foregroundColor: Color(0xFF203040),
        placeholderColor: Color(0xFF304050),
        borderColor: border,
        borderRadius: 20,
        padding: EdgeInsets.symmetric(horizontal: 24),
        minHeight: 52,
        textStyle: TextStyle(fontSize: 20),
        shadow: [],
        iconSize: 28,
        gap: 12,
      );

      await tester.pumpWidget(
        host(
          const FossSelect<String>(
            placeholder: 'Pick',
            style: style,
            items: _items,
          ),
        ),
      );

      final decorations = _shapeDecorations(tester);
      expect(
        decorations.any((d) => d.color == background),
        isTrue,
        reason: 'the override fill is applied',
      );
      final borders = decorations
          .map((d) => d.shape)
          .whereType<RoundedSuperellipseBorder>()
          .map((b) => b.side.color);
      expect(borders, contains(border));
    });

    testWidgets('an empty style leaves the trigger on theme defaults', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          const FossSelect<String>(
            placeholder: 'Pick',
            style: FossSelectStyle(),
            items: _items,
          ),
        ),
      );

      final surface = FossThemeData.light.colors.background;
      expect(
        _shapeDecorations(tester).any((d) => d.color == surface),
        isTrue,
        reason: 'null overrides inherit the resolved fill',
      );
    });

    testWidgets('the focused invalid trigger paints and repaints its ring', (
      tester,
    ) async {
      tester.binding.focusManager.highlightStrategy =
          FocusHighlightStrategy.alwaysTraditional;
      addTearDown(
        () => tester.binding.focusManager.highlightStrategy =
            FocusHighlightStrategy.automatic,
      );

      final error = ValueNotifier<String?>('Required');
      addTearDown(error.dispose);
      await tester.pumpWidget(
        host(
          ValueListenableBuilder<String?>(
            valueListenable: error,
            builder: (_, value, _) => FossSelect<String>(
              placeholder: 'Pick',
              errorText: value,
              items: _items,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      // Open then escape so focus returns to the trigger with the highlight on.
      await tester.tap(find.text('Pick'));
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      final colors = FossThemeData.light.colors;
      List<Color> triggerBorders() => _shapeDecorations(tester)
          .map((d) => d.shape)
          .whereType<RoundedSuperellipseBorder>()
          .map((b) => b.side.color)
          .toList();

      expect(
        triggerBorders(),
        contains(colors.destructive.withValues(alpha: 0.64)),
        reason: 'focused error border deepens',
      );

      // Change the error text while still focused: the ring repaints with the
      // same color, so the painter compares each field for equality.
      error.value = 'Missing';
      await tester.pumpAndSettle();
      expect(
        triggerBorders(),
        contains(colors.destructive.withValues(alpha: 0.64)),
      );

      // Clearing the error keeps focus, so the ring repaints in the focus tone.
      error.value = null;
      await tester.pumpAndSettle();
      expect(triggerBorders(), contains(colors.ring));
    });
  });
}
