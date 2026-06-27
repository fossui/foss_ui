import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foss_ui/foss_ui.dart';

import 'host.dart';

Finder _boxFinder = find.descendant(
  of: find.byType(FossTextField),
  matching: find.byType(DecoratedBox),
);

ShapeDecoration _decoration(WidgetTester tester) =>
    tester.widget<DecoratedBox>(_boxFinder).decoration as ShapeDecoration;

Color _borderColor(WidgetTester tester) =>
    (_decoration(tester).shape as RoundedSuperellipseBorder).side.color;

void main() {
  group('FossTextField input', () {
    testWidgets('reports text through onChanged', (tester) async {
      var value = '';
      await tester.pumpWidget(
        host(FossTextField(onChanged: (v) => value = v)),
      );

      await tester.enterText(find.byType(EditableText), 'hello');

      expect(value, 'hello');
    });

    testWidgets('reports submission through onSubmitted', (tester) async {
      String? submitted;
      await tester.pumpWidget(
        host(FossTextField(onSubmitted: (v) => submitted = v)),
      );

      await tester.enterText(find.byType(EditableText), 'done');
      await tester.testTextInput.receiveAction(TextInputAction.done);

      expect(submitted, 'done');
    });

    testWidgets('uses a supplied controller', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(host(FossTextField(controller: controller)));

      await tester.enterText(find.byType(EditableText), 'abc');

      expect(controller.text, 'abc');
    });
  });

  group('FossTextField placeholder', () {
    testWidgets('shows the hint while empty and hides it once filled', (
      tester,
    ) async {
      await tester.pumpWidget(host(const FossTextField(hintText: 'Email')));

      expect(find.text('Email'), findsOneWidget);

      await tester.enterText(find.byType(EditableText), 'a');
      await tester.pump();

      expect(find.text('Email'), findsNothing);
    });
  });

  group('FossTextField captions', () {
    testWidgets('renders helper text', (tester) async {
      await tester.pumpWidget(
        host(const FossTextField(helperText: 'Required')),
      );

      expect(find.text('Required'), findsOneWidget);
    });

    testWidgets('error text replaces the helper', (tester) async {
      await tester.pumpWidget(
        host(
          const FossTextField(helperText: 'Required', errorText: 'Too short'),
        ),
      );

      expect(find.text('Too short'), findsOneWidget);
      expect(find.text('Required'), findsNothing);
    });
  });

  group('FossTextField states', () {
    testWidgets('resting border uses the input token', (tester) async {
      await tester.pumpWidget(host(const FossTextField()));

      expect(_borderColor(tester), FossColors.light.input);
    });

    testWidgets('focus switches the border to the ring token', (tester) async {
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      await tester.pumpWidget(host(FossTextField(focusNode: focusNode)));

      focusNode.requestFocus();
      await tester.pump();

      expect(_borderColor(tester), FossColors.light.ring);
    });

    testWidgets('error tints the border with destructive', (tester) async {
      await tester.pumpWidget(host(const FossTextField(errorText: 'Bad')));

      expect(
        _borderColor(tester),
        FossColors.light.destructive.withValues(alpha: 0.36),
      );
    });

    testWidgets('disabled dims and does not focus on tap', (tester) async {
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      await tester.pumpWidget(
        host(FossTextField(enabled: false, focusNode: focusNode)),
      );

      await tester.tap(find.byType(FossTextField), warnIfMissed: false);
      await tester.pump();

      expect(focusNode.hasFocus, isFalse);
      expect(
        find.descendant(
          of: find.byType(FossTextField),
          matching: find.byType(Opacity),
        ),
        findsOneWidget,
      );
    });
  });

  group('FossTextField sizes', () {
    Future<double> heightFor(
      WidgetTester tester,
      FossTextFieldSize size,
    ) async {
      await tester.pumpWidget(host(FossTextField(size: size)));
      return tester.getSize(_boxFinder).height;
    }

    testWidgets('each size sets its box min-height', (tester) async {
      expect(await heightFor(tester, FossTextFieldSize.sm), 30);
      expect(await heightFor(tester, FossTextFieldSize.md), 34);
      expect(await heightFor(tester, FossTextFieldSize.lg), 38);
    });
  });

  group('FossTextField affixes', () {
    testWidgets('renders leading and trailing widgets', (tester) async {
      await tester.pumpWidget(
        host(
          const FossTextField(
            leading: Icon(IconData(0x1)),
            trailing: Icon(IconData(0x2)),
          ),
        ),
      );

      expect(find.byType(Icon), findsNWidgets(2));
    });
  });

  group('FossTextField accessibility', () {
    testWidgets('exposes a text field with its label', (tester) async {
      await tester.pumpWidget(host(const FossTextField(label: 'Email')));

      expect(find.bySemanticsLabel('Email'), findsWidgets);
    });

    testWidgets('meets the tap-target guideline', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(host(const FossTextField()));

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));

      handle.dispose();
    });

    testWidgets('label and value meet the contrast guideline', (tester) async {
      final controller = TextEditingController(text: 'Jane Doe');
      addTearDown(controller.dispose);
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        host(FossTextField(label: 'Name', controller: controller)),
      );

      await expectLater(tester, meetsGuideline(textContrastGuideline));

      handle.dispose();
    });
  });

  group('FossTextField responsive', () {
    testWidgets('box grows with the text scale', (tester) async {
      final controller = TextEditingController(text: 'Ag');
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(child: FossTextField(controller: controller)),
          ),
          builder: (context, child) => MediaQuery.withClampedTextScaling(
            minScaleFactor: 2,
            maxScaleFactor: 2,
            child: child!,
          ),
        ),
      );

      // The md box is 34 tall at 1x; doubled text pushes it past that.
      expect(tester.getSize(_boxFinder).height, greaterThan(34));
    });

    testWidgets('lays the leading slot at the start under RTL', (tester) async {
      await tester.pumpWidget(
        host(
          const Directionality(
            textDirection: TextDirection.rtl,
            child: FossTextField(
              leading: Icon(IconData(0x1)),
              trailing: Icon(IconData(0x2)),
            ),
          ),
        ),
      );

      final leading = tester.getCenter(find.byIcon(const IconData(0x1)));
      final trailing = tester.getCenter(find.byIcon(const IconData(0x2)));
      // Start is on the right in RTL, so leading sits to the right of trailing.
      expect(leading.dx, greaterThan(trailing.dx));
    });
  });
}
