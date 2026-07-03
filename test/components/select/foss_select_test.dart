import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fossui/fossui.dart';

import 'host.dart';

const List<FossSelectItem<String>> _items = [
  FossSelectItem(value: 'a', label: 'Apple'),
  FossSelectItem(value: 'b', label: 'Banana'),
  FossSelectItem(value: 'c', label: 'Cherry', enabled: false),
];

void main() {
  group('FossSelect', () {
    testWidgets('shows the placeholder when nothing is picked', (tester) async {
      await tester.pumpWidget(
        host(
          const FossSelect<String>(
            placeholder: 'Choose a fruit',
            items: _items,
          ),
        ),
      );

      expect(find.text('Choose a fruit'), findsOneWidget);
      expect(find.text('Apple'), findsNothing);
    });

    testWidgets('shows the picked value label in the trigger', (tester) async {
      await tester.pumpWidget(
        host(
          const FossSelect<String>(
            value: 'b',
            placeholder: 'Choose a fruit',
            items: _items,
          ),
        ),
      );

      expect(find.text('Banana'), findsOneWidget);
      expect(find.text('Choose a fruit'), findsNothing);
    });

    testWidgets('opens the popup on tap and lists the items', (tester) async {
      await tester.pumpWidget(
        host(
          FossSelect<String>(
            placeholder: 'Pick',
            items: _items,
            onChanged: (_) {},
          ),
        ),
      );

      await tester.tap(find.text('Pick'));
      await tester.pumpAndSettle();

      expect(find.text('Apple'), findsOneWidget);
      expect(find.text('Banana'), findsOneWidget);
      expect(find.text('Cherry'), findsOneWidget);
    });

    testWidgets('picking a row reports the value and closes', (tester) async {
      String? picked;
      await tester.pumpWidget(
        host(
          FossSelect<String>(
            placeholder: 'Pick',
            items: _items,
            onChanged: (v) => picked = v,
          ),
        ),
      );

      await tester.tap(find.text('Pick'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Banana'));
      await tester.pumpAndSettle();

      expect(picked, 'b');
      expect(find.text('Cherry'), findsNothing, reason: 'popup closed');
    });

    testWidgets('a disabled row does not report a pick', (tester) async {
      String? picked;
      await tester.pumpWidget(
        host(
          FossSelect<String>(
            placeholder: 'Pick',
            items: _items,
            onChanged: (v) => picked = v,
          ),
        ),
      );

      await tester.tap(find.text('Pick'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cherry'), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(picked, isNull);
    });

    testWidgets('a null onChanged disables the trigger', (tester) async {
      await tester.pumpWidget(
        host(const FossSelect<String>(placeholder: 'Pick', items: _items)),
      );

      await tester.tap(find.text('Pick'), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.text('Apple'), findsNothing, reason: 'stayed closed');
    });

    testWidgets('an outside tap dismisses the popup', (tester) async {
      await tester.pumpWidget(
        host(
          FossSelect<String>(
            placeholder: 'Pick',
            items: _items,
            onChanged: (_) {},
          ),
        ),
      );

      await tester.tap(find.text('Pick'));
      await tester.pumpAndSettle();
      expect(find.text('Banana'), findsOneWidget);

      await tester.tapAt(const Offset(400, 550));
      await tester.pumpAndSettle();
      expect(find.text('Banana'), findsNothing);
    });

    testWidgets('renders the field label above the trigger', (tester) async {
      await tester.pumpWidget(
        host(
          const FossSelect<String>(
            label: 'Fruit',
            placeholder: 'Pick',
            items: _items,
          ),
        ),
      );

      expect(find.text('Fruit'), findsOneWidget);
    });

    testWidgets('reduce motion opens and closes without an animation', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          reduceMotion: true,
          FossSelect<String>(
            placeholder: 'Pick',
            items: _items,
            onChanged: (_) {},
          ),
        ),
      );

      await tester.tap(find.text('Pick'));
      await tester.pumpAndSettle();
      expect(find.text('Banana'), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.text('Banana'), findsNothing);
    });

    testWidgets('hovering a row moves the highlight so enter picks it', (
      tester,
    ) async {
      String? picked;
      await tester.pumpWidget(
        host(
          FossSelect<String>(
            placeholder: 'Pick',
            items: _items,
            onChanged: (v) => picked = v,
          ),
        ),
      );

      await tester.tap(find.text('Pick'));
      await tester.pumpAndSettle();

      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);
      await gesture.moveTo(tester.getCenter(find.text('Banana')));
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(picked, 'b', reason: 'hover moved the highlight off Apple');
    });

    testWidgets('renders a leading icon on a row', (tester) async {
      const iconKey = Key('leading-icon');
      await tester.pumpWidget(
        host(
          FossSelect<String>(
            placeholder: 'Pick',
            onChanged: (_) {},
            items: const [
              FossSelectItem(
                value: 'a',
                label: 'Apple',
                icon: SizedBox(key: iconKey),
              ),
              FossSelectItem(value: 'b', label: 'Banana'),
            ],
          ),
        ),
      );

      await tester.tap(find.text('Pick'));
      await tester.pumpAndSettle();

      expect(find.byKey(iconKey), findsOneWidget);
    });

    testWidgets('the popup flips above when there is no room below', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          alignment: Alignment.bottomCenter,
          FossSelect<String>(
            placeholder: 'Pick',
            items: _items,
            onChanged: (_) {},
          ),
        ),
      );

      await tester.tap(find.text('Pick'));
      await tester.pumpAndSettle();

      final trigger = tester.getRect(find.text('Pick'));
      final row = tester.getRect(find.text('Banana'));
      expect(
        row.center.dy,
        lessThan(trigger.top),
        reason: 'the popup sits above the trigger',
      );
    });
  });
}
