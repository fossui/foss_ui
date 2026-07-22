@Tags(['golden'])
library;

// goldenTest registers a test and returns a future it manages itself, like
// testWidgets; the calls are intentionally not awaited.
// ignore_for_file: discarded_futures

import 'package:alchemist/alchemist.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fossui/fossui.dart';

import '../../support/golden_matrix.dart';

/// The skeleton sweeps shape x theme. State, direction, and textScale are
/// dropped: it has no interactive state, no text, and no directional layout.
/// The shimmer is captured at frame 0 (band centered), a deterministic point.
List<GoldenTestScenario> _scenarios(FossThemeData data) => [
  GoldenTestScenario(
    name: 'line',
    child: themed(data, const FossSkeleton(width: 120, height: 16)),
  ),
  GoldenTestScenario(
    name: 'block',
    child: themed(data, const FossSkeleton(width: 160, height: 48)),
  ),
  GoldenTestScenario(
    name: 'circle',
    child: themed(data, const FossSkeleton.circle(size: 48)),
  ),
];

// The shimmer never settles, so the default settle-based pump would hang.
// Pump a single frame to capture frame 0, a deterministic point in the loop.
Future<void> _pumpOneFrame(WidgetTester tester) => tester.pump();

void main() {
  goldenTest(
    'skeleton (light)',
    fileName: 'skeleton',
    pumpBeforeTest: _pumpOneFrame,
    builder: () => GoldenTestGroup(
      columns: 3,
      children: _scenarios(FossThemeData.light),
    ),
  );

  goldenTest(
    'skeleton (dark)',
    fileName: 'skeleton_dark',
    pumpBeforeTest: _pumpOneFrame,
    builder: () => GoldenTestGroup(
      columns: 3,
      children: _scenarios(FossThemeData.dark),
    ),
  );
}
