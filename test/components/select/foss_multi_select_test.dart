import 'package:flutter_test/flutter_test.dart';
import 'package:fossui/fossui.dart';

import 'host.dart';

const List<FossSelectItem<String>> _items = [
  FossSelectItem(value: 'a', label: 'Apple'),
  FossSelectItem(value: 'b', label: 'Banana'),
  FossSelectItem(value: 'c', label: 'Cherry'),
];

void main() {
  group('FossMultiSelect', () {
    testWidgets('shows the placeholder when empty', (tester) async {
      await tester.pumpWidget(
        host(
          const FossMultiSelect<String>(placeholder: 'Tags', items: _items),
        ),
      );

      expect(find.text('Tags'), findsOneWidget);
    });

    testWidgets('shows a count of picks in the trigger', (tester) async {
      await tester.pumpWidget(
        host(
          const FossMultiSelect<String>(
            values: {'a', 'c'},
            placeholder: 'Tags',
            items: _items,
          ),
        ),
      );

      expect(find.text('2 selected'), findsOneWidget);
      expect(find.text('Tags'), findsNothing);
    });

    testWidgets('a pick toggles the value and keeps the popup open', (
      tester,
    ) async {
      Set<String>? next;
      await tester.pumpWidget(
        host(
          FossMultiSelect<String>(
            placeholder: 'Tags',
            items: _items,
            onChanged: (v) => next = v,
          ),
        ),
      );

      await tester.tap(find.text('Tags'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Banana'));
      await tester.pumpAndSettle();

      expect(next, {'b'});
      expect(find.text('Apple'), findsOneWidget, reason: 'popup still open');
    });

    testWidgets('picking an already-selected value removes it', (tester) async {
      Set<String>? next;
      await tester.pumpWidget(
        host(
          FossMultiSelect<String>(
            values: const {'b'},
            placeholder: 'Tags',
            items: _items,
            onChanged: (v) => next = v,
          ),
        ),
      );

      await tester.tap(find.text('1 selected'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Banana'));
      await tester.pumpAndSettle();

      expect(next, isEmpty);
    });
  });
}
