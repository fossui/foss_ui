@Tags(['golden'])
library;

// goldenTest registers a test and returns a future it manages itself, like
// testWidgets; the calls are intentionally not awaited.
// ignore_for_file: discarded_futures

import 'package:alchemist/alchemist.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fossui/fossui.dart';

import '../../support/golden_matrix.dart';

/// One cell per type step and one per weight, so the golden pins the full scale
/// (size, line height, letter spacing) and every weight of the bundled font.
List<GoldenTestScenario> _scenarios(FossThemeData data) => [
  for (final size in FossTextSize.values)
    GoldenTestScenario(
      name: size.name,
      child: themed(data, FossText('The quick brown fox', size: size)),
    ),
  for (final weight in FossTextWeight.values)
    GoldenTestScenario(
      name: weight.name,
      child: themed(
        data,
        FossText('The quick brown fox', size: FossTextSize.lg, weight: weight),
      ),
    ),
];

void main() {
  goldenTest(
    'text (light)',
    fileName: 'text',
    builder: () =>
        GoldenTestGroup(columns: 2, children: _scenarios(FossThemeData.light)),
  );

  goldenTest(
    'text (dark)',
    fileName: 'text_dark',
    builder: () =>
        GoldenTestGroup(columns: 2, children: _scenarios(FossThemeData.dark)),
  );
}
