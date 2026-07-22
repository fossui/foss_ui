@Tags(['golden'])
library;

// goldenTest registers a test and returns a future it manages itself, like
// testWidgets; the calls are intentionally not awaited.
// ignore_for_file: discarded_futures

import 'package:alchemist/alchemist.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fossui/fossui.dart';

import '../../support/golden_matrix.dart';

const _items = <FossAccordionItem>[
  FossAccordionItem(
    value: 'a',
    title: Text('Is it accessible?'),
    child: Text('Yes. It follows the accessibility pattern.'),
  ),
  FossAccordionItem(
    value: 'b',
    title: Text('Is it styled?'),
    child: Text('Yes. It reads its colors and type from the theme.'),
  ),
  FossAccordionItem(
    value: 'c',
    title: Text('Is it animated?'),
    child: Text('Yes. The chevron rotates and the panel slides.'),
  ),
];

const _disabled = <FossAccordionItem>[
  FossAccordionItem(
    value: 'a',
    title: Text('Enabled'),
    child: Text('Open me.'),
  ),
  FossAccordionItem(
    value: 'b',
    title: Text('Disabled'),
    child: Text('Not this one.'),
    enabled: false,
  ),
];

Widget _sized(FossAccordion accordion) =>
    SizedBox(width: 320, child: accordion);

/// The accordion sweeps its resting states: fully collapsed, one section
/// expanded (single mode), two expanded (multiple mode), and a disabled item.
/// The chevron rotation, hairline divider, and muted panel text are pinned;
/// the focus ring is covered by the widget tests.
List<GoldenTestScenario> _scenarios(FossThemeData data) => [
  GoldenTestScenario(
    name: 'collapsed',
    child: themed(data, _sized(const FossAccordion(children: _items))),
  ),
  GoldenTestScenario(
    name: 'expanded',
    child: themed(
      data,
      _sized(const FossAccordion(initialValue: {'a'}, children: _items)),
    ),
  ),
  GoldenTestScenario(
    name: 'multiple',
    child: themed(
      data,
      _sized(
        const FossAccordion(
          multiple: true,
          initialValue: {'a', 'b'},
          children: _items,
        ),
      ),
    ),
  ),
  GoldenTestScenario(
    name: 'disabled',
    child: themed(
      data,
      _sized(const FossAccordion(initialValue: {'a'}, children: _disabled)),
    ),
  ),
];

void main() {
  goldenTest(
    'accordion (light)',
    fileName: 'accordion',
    builder: () =>
        GoldenTestGroup(columns: 2, children: _scenarios(FossThemeData.light)),
  );

  goldenTest(
    'accordion (dark)',
    fileName: 'accordion_dark',
    builder: () =>
        GoldenTestGroup(columns: 2, children: _scenarios(FossThemeData.dark)),
  );
}
