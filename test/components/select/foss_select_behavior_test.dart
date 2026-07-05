import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fossui/fossui.dart';

import 'host.dart';

const List<FossSelectItem<String>> _items = [
  FossSelectItem(value: 'a', label: 'Apple'),
  FossSelectItem(value: 'b', label: 'Banana'),
  FossSelectItem(value: 'c', label: 'Cherry'),
];

void main() {
  group('FossSelect keyboard', () {
    testWidgets('arrow down opens the closed, focused trigger', (tester) async {
      await tester.pumpWidget(
        host(
          FossSelect<String>(
            placeholder: 'Pick',
            items: _items,
            onChanged: (_) {},
          ),
        ),
      );

      // Open then Escape so the trigger regains focus while closed, then Down
      // should reopen it.
      await tester.tap(find.text('Pick'));
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.text('Banana'), findsNothing);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      expect(find.text('Banana'), findsOneWidget);
    });
  });

  group('FossSelect scroll', () {
    // The full-screen tap barrier blocks a drag from reaching the list, so the
    // scroll is driven programmatically, the case the barrier cannot catch.
    testWidgets('closes the popup when an ancestor scrolls', (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        FossTheme(
          data: FossThemeData.light,
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: MediaQuery(
              data: const MediaQueryData(size: Size(800, 600)),
              child: Overlay(
                initialEntries: [
                  OverlayEntry(
                    builder: (_) => ListView(
                      controller: controller,
                      children: [
                        const SizedBox(height: 80),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: FossSelect<String>(
                            placeholder: 'Pick',
                            items: _items,
                            onChanged: (_) {},
                          ),
                        ),
                        const SizedBox(height: 1200),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Pick'));
      await tester.pumpAndSettle();
      expect(find.text('Banana'), findsOneWidget);

      controller.jumpTo(60);
      await tester.pumpAndSettle();
      expect(find.text('Banana'), findsNothing);
    });
  });

  group('FossMultiSelect label', () {
    testWidgets('uses a custom selectionLabel builder', (tester) async {
      await tester.pumpWidget(
        host(
          FossMultiSelect<String>(
            placeholder: 'Pick',
            items: _items,
            values: const {'a', 'b'},
            selectionLabel: (count) => '$count chosen',
            onChanged: (_) {},
          ),
        ),
      );

      expect(find.text('2 chosen'), findsOneWidget);
    });

    testWidgets('defaults to "N selected"', (tester) async {
      await tester.pumpWidget(
        host(
          FossMultiSelect<String>(
            placeholder: 'Pick',
            items: _items,
            values: const {'a'},
            onChanged: (_) {},
          ),
        ),
      );

      expect(find.text('1 selected'), findsOneWidget);
    });
  });
}
