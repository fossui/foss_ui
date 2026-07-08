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

// A no-op change handler keeps each scenario interactive, so the resting rim,
// shadow, and full-opacity text render instead of the disabled wash.
void _noop(Object? _) {}

/// The checkbox sweeps its resting states: unchecked, checked, indeterminate,
/// a bare box, checked with a description, invalid, disabled, and the card
/// group. Focus, RTL, and tap targets are covered by the widget tests; the
/// golden locks the static appearance.
List<GoldenTestScenario> _scenarios(FossThemeData data) => [
  GoldenTestScenario(
    name: 'unchecked',
    child: themed(data, FossCheckbox(label: 'Notify me', onChanged: _noop)),
  ),
  GoldenTestScenario(
    name: 'checked',
    child: themed(
      data,
      FossCheckbox(value: true, label: 'Notify me', onChanged: _noop),
    ),
  ),
  GoldenTestScenario(
    name: 'indeterminate',
    child: themed(
      data,
      FossCheckbox(value: null, label: 'Notify me', onChanged: _noop),
    ),
  ),
  GoldenTestScenario(
    name: 'bare',
    child: themed(data, FossCheckbox(onChanged: _noop)),
  ),
  GoldenTestScenario(
    name: 'description',
    child: themed(
      data,
      SizedBox(
        width: 220,
        child: FossCheckbox(
          value: true,
          label: 'Email',
          description: 'Notify by email',
          onChanged: _noop,
        ),
      ),
    ),
  ),
  GoldenTestScenario(
    name: 'error',
    child: themed(
      data,
      FossCheckbox(
        label: 'Accept terms',
        errorText: 'This field is required',
        onChanged: _noop,
      ),
    ),
  ),
  GoldenTestScenario(
    name: 'disabled',
    child: themed(
      data,
      const FossCheckbox(value: true, label: 'Notify me', enabled: false),
    ),
  ),
  GoldenTestScenario(
    name: 'group',
    child: themed(
      data,
      SizedBox(
        width: 220,
        child: FossCheckboxGroup<String>(
          label: 'Frameworks',
          values: const {'next'},
          onChanged: (_) {},
          children: const [
            FossCheckboxItem(value: 'next', label: 'Next.js'),
            FossCheckboxItem(value: 'vite', label: 'Vite'),
          ],
        ),
      ),
    ),
  ),
  GoldenTestScenario(
    name: 'card',
    child: themed(
      data,
      SizedBox(
        width: 220,
        child: FossCheckboxGroup<String>(
          variant: FossCheckboxGroupVariant.card,
          values: const {'next'},
          onChanged: (_) {},
          children: const [
            FossCheckboxItem(
              value: 'next',
              label: 'Next.js',
              description: 'React framework',
            ),
            FossCheckboxItem(value: 'vite', label: 'Vite'),
          ],
        ),
      ),
    ),
  ),
];

void main() {
  goldenTest(
    'checkbox (light)',
    fileName: 'checkbox',
    builder: () =>
        GoldenTestGroup(columns: 4, children: _scenarios(FossThemeData.light)),
  );

  goldenTest(
    'checkbox (dark)',
    fileName: 'checkbox_dark',
    builder: () =>
        GoldenTestGroup(columns: 4, children: _scenarios(FossThemeData.dark)),
  );
}
