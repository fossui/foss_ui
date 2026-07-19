@Tags(['golden'])
library;

// goldenTest registers a test and returns a future it manages itself, like
// testWidgets; the calls are intentionally not awaited.
// ignore_for_file: discarded_futures

import 'package:alchemist/alchemist.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fossui/fossui.dart';

import '../../support/golden_matrix.dart';

/// Sweeps size x state, the axes that change the resting look, plus the grouped
/// and masked variants. The active slot (focus ring + caret), typing, paste,
/// RTL, and textScale are exercised by the widget tests.
List<GoldenTestScenario> _scenarios(FossThemeData data) => [
  for (final size in FossOtpFieldSize.values) ...[
    GoldenTestScenario(
      name: '${size.name} empty',
      child: themed(data, FossOtpField(length: 4, size: size)),
    ),
    GoldenTestScenario(
      name: '${size.name} filled',
      child: themed(data, FossOtpField(length: 4, size: size, value: '12')),
    ),
    GoldenTestScenario(
      name: '${size.name} error',
      child: themed(
        data,
        FossOtpField(length: 4, size: size, value: '12', error: true),
      ),
    ),
    GoldenTestScenario(
      name: '${size.name} disabled',
      child: themed(
        data,
        FossOtpField(length: 4, size: size, value: '12', enabled: false),
      ),
    ),
  ],
  GoldenTestScenario(
    name: 'grouped',
    child: themed(
      data,
      const FossOtpField(length: 6, value: '123', groups: [3, 3]),
    ),
  ),
  GoldenTestScenario(
    name: 'masked',
    child: themed(
      data,
      const FossOtpField(length: 4, value: '12', obscure: true),
    ),
  ),
];

void main() {
  goldenTest(
    'otp field (light)',
    fileName: 'otp_field',
    builder: () => GoldenTestGroup(
      columns: 4,
      children: _scenarios(FossThemeData.light),
    ),
  );

  goldenTest(
    'otp field (dark)',
    fileName: 'otp_field_dark',
    builder: () => GoldenTestGroup(
      columns: 4,
      children: _scenarios(FossThemeData.dark),
    ),
  );
}
