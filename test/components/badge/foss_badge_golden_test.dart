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

/// One cell per variant, each showing the three sizes so the golden pins the
/// full variant by size matrix: solid and soft fills, the outline border, the
/// tint alphas, and the superellipse corners.
List<GoldenTestScenario> _scenarios(FossThemeData data) => [
  for (final variant in FossBadgeVariant.values)
    GoldenTestScenario(
      name: variant.name,
      child: themed(
        data,
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            for (final size in FossBadgeSize.values)
              FossBadge(
                label: const Text('Badge'),
                variant: variant,
                size: size,
              ),
          ],
        ),
      ),
    ),
];

void main() {
  goldenTest(
    'badge (light)',
    fileName: 'badge',
    builder: () =>
        GoldenTestGroup(columns: 4, children: _scenarios(FossThemeData.light)),
  );

  goldenTest(
    'badge (dark)',
    fileName: 'badge_dark',
    builder: () =>
        GoldenTestGroup(columns: 4, children: _scenarios(FossThemeData.dark)),
  );
}
