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

const List<FossSelectItem<String>> _items = [
  FossSelectItem(value: 'a', label: 'Monthly'),
  FossSelectItem(value: 'b', label: 'Yearly'),
];

Widget _trigger(Widget child) => SizedBox(width: 220, child: child);

// The closed trigger sweeps its resting appearance: the three sizes, a picked
// value, error, disabled, and the multi-select count. The open popup, focus,
// and keyboard are covered by the widget tests.
List<GoldenTestScenario> _scenarios(FossThemeData data) => [
  GoldenTestScenario(
    name: 'sm',
    child: themed(
      data,
      _trigger(
        const FossSelect<String>(
          size: FossSelectSize.sm,
          placeholder: 'Plan',
          items: _items,
        ),
      ),
    ),
  ),
  GoldenTestScenario(
    name: 'md',
    child: themed(
      data,
      _trigger(
        const FossSelect<String>(placeholder: 'Plan', items: _items),
      ),
    ),
  ),
  GoldenTestScenario(
    name: 'lg',
    child: themed(
      data,
      _trigger(
        const FossSelect<String>(
          size: FossSelectSize.lg,
          placeholder: 'Plan',
          items: _items,
        ),
      ),
    ),
  ),
  GoldenTestScenario(
    name: 'selected',
    child: themed(
      data,
      _trigger(const FossSelect<String>(value: 'b', items: _items)),
    ),
  ),
  GoldenTestScenario(
    name: 'label',
    child: themed(
      data,
      _trigger(
        const FossSelect<String>(
          label: 'Billing',
          placeholder: 'Plan',
          items: _items,
        ),
      ),
    ),
  ),
  GoldenTestScenario(
    name: 'error',
    child: themed(
      data,
      _trigger(
        const FossSelect<String>(
          placeholder: 'Plan',
          errorText: 'Required',
          items: _items,
        ),
      ),
    ),
  ),
  GoldenTestScenario(
    name: 'disabled',
    child: themed(
      data,
      _trigger(
        const FossSelect<String>(
          placeholder: 'Plan',
          enabled: false,
          items: _items,
        ),
      ),
    ),
  ),
  GoldenTestScenario(
    name: 'multi',
    child: themed(
      data,
      _trigger(
        const FossMultiSelect<String>(values: {'a', 'b'}, items: _items),
      ),
    ),
  ),
];

void main() {
  goldenTest(
    'select (light)',
    fileName: 'select',
    builder: () =>
        GoldenTestGroup(columns: 4, children: _scenarios(FossThemeData.light)),
  );

  goldenTest(
    'select (dark)',
    fileName: 'select_dark',
    builder: () =>
        GoldenTestGroup(columns: 4, children: _scenarios(FossThemeData.dark)),
  );
}
