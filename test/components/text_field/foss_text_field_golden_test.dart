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

/// The field sweeps size x state, the axes that change its resting look. Focus,
/// RTL, and textScale are exercised by the widget tests; the golden locks the
/// empty, filled, error, and disabled appearance at every size.
List<GoldenTestScenario> _scenarios(FossThemeData data) => [
  for (final size in FossTextFieldSize.values) ...[
    GoldenTestScenario(
      name: '${size.name} empty',
      child: themed(
        data,
        SizedBox(
          width: 240,
          child: FossTextField(size: size, label: 'Label', hintText: 'Email'),
        ),
      ),
    ),
    GoldenTestScenario(
      name: '${size.name} filled',
      child: themed(
        data,
        SizedBox(
          width: 240,
          child: FossTextField(
            size: size,
            label: 'Label',
            controller: TextEditingController(text: 'jane@example.com'),
          ),
        ),
      ),
    ),
    GoldenTestScenario(
      name: '${size.name} error',
      child: themed(
        data,
        SizedBox(
          width: 240,
          child: FossTextField(
            size: size,
            label: 'Label',
            controller: TextEditingController(text: 'nope'),
            errorText: 'Enter a valid email',
          ),
        ),
      ),
    ),
    GoldenTestScenario(
      name: '${size.name} disabled',
      child: themed(
        data,
        SizedBox(
          width: 240,
          child: FossTextField(
            size: size,
            label: 'Label',
            enabled: false,
            controller: TextEditingController(text: 'locked'),
          ),
        ),
      ),
    ),
  ],
];

void main() {
  goldenTest(
    'text field (light)',
    fileName: 'text_field',
    builder: () => GoldenTestGroup(
      columns: 4,
      children: _scenarios(FossThemeData.light),
    ),
  );

  goldenTest(
    'text field (dark)',
    fileName: 'text_field_dark',
    builder: () => GoldenTestGroup(
      columns: 4,
      children: _scenarios(FossThemeData.dark),
    ),
  );
}
