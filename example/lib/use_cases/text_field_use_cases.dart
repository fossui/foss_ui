import 'package:flutter/widgets.dart';
import 'package:foss_ui/foss_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Playground', type: FossTextField)
Widget playgroundTextField(BuildContext context) {
  final size = context.knobs.object.dropdown(
    label: 'Size',
    options: FossTextFieldSize.values,
    initialOption: FossTextFieldSize.md,
    labelBuilder: (s) => s.name,
  );
  final label = context.knobs.string(label: 'Label', initialValue: 'Email');
  final hint = context.knobs.string(label: 'Hint', initialValue: 'you@x.com');
  final helper = context.knobs.string(label: 'Helper');
  final error = context.knobs.string(label: 'Error');
  final enabled = context.knobs.boolean(label: 'Enabled', initialValue: true);
  final leading = context.knobs.boolean(label: 'Leading icon');

  return Center(
    child: SizedBox(
      width: 280,
      child: FossTextField(
        size: size,
        label: label.isEmpty ? null : label,
        hintText: hint.isEmpty ? null : hint,
        helperText: helper.isEmpty ? null : helper,
        errorText: error.isEmpty ? null : error,
        enabled: enabled,
        leading: leading ? const Icon(LucideIcons.mail) : null,
      ),
    ),
  );
}

@widgetbook.UseCase(name: 'States', type: FossTextField)
Widget statesTextField(BuildContext context) => Center(
  child: SizedBox(
    width: 280,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: [
        const FossTextField(label: 'Empty', hintText: 'Placeholder'),
        FossTextField(
          label: 'Filled',
          controller: TextEditingController(text: 'jane@example.com'),
        ),
        FossTextField(
          label: 'Error',
          controller: TextEditingController(text: 'nope'),
          errorText: 'Enter a valid email',
        ),
        const FossTextField(
          label: 'Disabled',
          enabled: false,
          hintText: 'Unavailable',
        ),
      ],
    ),
  ),
);
