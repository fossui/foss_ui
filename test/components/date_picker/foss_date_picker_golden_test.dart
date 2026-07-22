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

Widget _field(Widget child) => SizedBox(width: 280, child: child);

// The closed trigger sweeps its resting appearance: single and range, empty and
// filled, and disabled. The open popup, focus, and keyboard are covered by the
// widget tests, and the calendar grid by its own goldens.
List<GoldenTestScenario> _scenarios(FossThemeData data) => [
  GoldenTestScenario(
    name: 'single-empty',
    child: themed(
      data,
      _field(FossDatePicker.single(selected: null, onSelected: (_) {})),
    ),
  ),
  GoldenTestScenario(
    name: 'single-filled',
    child: themed(
      data,
      _field(
        FossDatePicker.single(
          selected: DateTime(2026, 3, 6),
          onSelected: (_) {},
        ),
      ),
    ),
  ),
  GoldenTestScenario(
    name: 'range-empty',
    child: themed(
      data,
      _field(FossDatePicker.range(selected: null, onSelected: (_) {})),
    ),
  ),
  GoldenTestScenario(
    name: 'range-filled',
    child: themed(
      data,
      _field(
        FossDatePicker.range(
          selected: FossDateRange(
            start: DateTime(2026, 7, 9),
            end: DateTime(2026, 7, 16),
          ),
          onSelected: (_) {},
        ),
      ),
    ),
  ),
  GoldenTestScenario(
    name: 'disabled',
    child: themed(
      data,
      _field(
        FossDatePicker.single(
          selected: DateTime(2026, 3, 6),
          onSelected: (_) {},
          enabled: false,
        ),
      ),
    ),
  ),
];

void main() {
  goldenTest(
    'date picker (light)',
    fileName: 'date_picker',
    builder: () =>
        GoldenTestGroup(columns: 2, children: _scenarios(FossThemeData.light)),
  );

  goldenTest(
    'date picker (dark)',
    fileName: 'date_picker_dark',
    builder: () =>
        GoldenTestGroup(columns: 2, children: _scenarios(FossThemeData.dark)),
  );
}
