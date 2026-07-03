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

Widget _select(void Function(String?) onChanged) => FossSelect<String>(
  placeholder: 'Pick',
  items: _items,
  onChanged: onChanged,
);

void main() {
  group('FossSelect keyboard', () {
    testWidgets('arrow down then enter picks the next enabled row', (
      tester,
    ) async {
      String? picked;
      await tester.pumpWidget(host(_select((v) => picked = v)));

      await tester.tap(find.text('Pick'));
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(picked, 'b', reason: 'initial highlight Apple, down to Banana');
    });

    testWidgets('type-ahead jumps the highlight to a matching label', (
      tester,
    ) async {
      String? picked;
      await tester.pumpWidget(host(_select((v) => picked = v)));

      await tester.tap(find.text('Pick'));
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.keyC);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(picked, 'c');
    });

    testWidgets('arrow up wraps the highlight to the last row', (tester) async {
      String? picked;
      await tester.pumpWidget(host(_select((v) => picked = v)));

      await tester.tap(find.text('Pick'));
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(picked, 'c', reason: 'up from Apple wraps to Cherry');
    });

    testWidgets('type-ahead extends the query within the window', (
      tester,
    ) async {
      String? picked;
      await tester.pumpWidget(host(_select((v) => picked = v)));

      await tester.tap(find.text('Pick'));
      await tester.pumpAndSettle();
      // 'b' then 'a' in quick succession matches "ba" (Banana); a reset would
      // leave "a" and jump to Apple instead.
      await tester.sendKeyEvent(LogicalKeyboardKey.keyB);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(picked, 'b');
    });

    testWidgets('activating the focused trigger opens the popup', (
      tester,
    ) async {
      await tester.pumpWidget(host(_select((_) {})));

      final context = tester.element(find.byType(GestureDetector));
      Actions.invoke(context, const ActivateIntent());
      await tester.pumpAndSettle();

      expect(find.text('Banana'), findsOneWidget);
    });

    testWidgets('escape closes the popup', (tester) async {
      await tester.pumpWidget(host(_select((_) {})));

      await tester.tap(find.text('Pick'));
      await tester.pumpAndSettle();
      expect(find.text('Banana'), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      expect(find.text('Banana'), findsNothing);
    });
  });
}
