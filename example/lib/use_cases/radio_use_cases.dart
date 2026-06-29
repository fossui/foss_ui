import 'package:flutter/widgets.dart';
import 'package:foss_ui/foss_ui.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Playground', type: FossRadioGroup)
Widget playgroundRadioGroup(BuildContext context) {
  final variant = context.knobs.object.dropdown(
    label: 'Variant',
    options: FossRadioGroupVariant.values,
    initialOption: FossRadioGroupVariant.plain,
    labelBuilder: (v) => v.name,
  );
  final label = context.knobs.string(label: 'Label', initialValue: 'Plan');
  final error = context.knobs.string(label: 'Error');
  final descriptions = context.knobs.boolean(label: 'Descriptions');
  final enabled = context.knobs.boolean(label: 'Enabled', initialValue: true);

  return Center(
    child: SizedBox(
      width: 280,
      child: _RadioDemo(
        variant: variant,
        label: label.isEmpty ? null : label,
        errorText: error.isEmpty ? null : error,
        showDescriptions: descriptions,
        enabled: enabled,
      ),
    ),
  );
}

@widgetbook.UseCase(name: 'States', type: FossRadioGroup)
Widget statesRadioGroup(BuildContext context) => Center(
  child: SizedBox(
    width: 280,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 24,
      children: [
        FossRadioGroup<String>(
          label: 'Default',
          groupValue: 'a',
          onChanged: (_) {},
          children: const [
            FossRadio(value: 'a', label: 'Selected'),
            FossRadio(value: 'b', label: 'Unselected'),
          ],
        ),
        FossRadioGroup<String>(
          label: 'Descriptions',
          groupValue: 'a',
          onChanged: (_) {},
          children: const [
            FossRadio(
              value: 'a',
              label: 'Monthly',
              description: 'Billed every month',
            ),
            FossRadio(value: 'b', label: 'Yearly', description: 'Save 16%'),
          ],
        ),
        FossRadioGroup<String>(
          label: 'Error',
          errorText: 'Select a plan',
          onChanged: (_) {},
          children: const [
            FossRadio(value: 'a', label: 'Monthly'),
            FossRadio(value: 'b', label: 'Yearly'),
          ],
        ),
        const FossRadioGroup<String>(
          label: 'Disabled',
          groupValue: 'a',
          enabled: false,
          children: [
            FossRadio(value: 'a', label: 'Monthly'),
            FossRadio(value: 'b', label: 'Yearly'),
          ],
        ),
        FossRadioGroup<String>(
          label: 'Card',
          variant: FossRadioGroupVariant.card,
          groupValue: 'a',
          onChanged: (_) {},
          children: const [
            FossRadio(
              value: 'a',
              label: 'Monthly',
              description: 'Billed monthly',
            ),
            FossRadio(
              value: 'b',
              label: 'Yearly',
              description: 'Billed yearly',
            ),
          ],
        ),
      ],
    ),
  ),
);

class _RadioDemo extends StatefulWidget {
  const _RadioDemo({
    required this.variant,
    required this.showDescriptions,
    required this.enabled,
    this.label,
    this.errorText,
  });

  final FossRadioGroupVariant variant;
  final bool showDescriptions;
  final bool enabled;
  final String? label;
  final String? errorText;

  @override
  State<_RadioDemo> createState() => _RadioDemoState();
}

class _RadioDemoState extends State<_RadioDemo> {
  String? _value = 'monthly';

  @override
  Widget build(BuildContext context) => FossRadioGroup<String>(
    variant: widget.variant,
    label: widget.label,
    errorText: widget.errorText,
    enabled: widget.enabled,
    groupValue: _value,
    onChanged: (value) => setState(() => _value = value),
    children: [
      FossRadio(
        value: 'monthly',
        label: 'Monthly',
        description: widget.showDescriptions ? 'Billed every month' : null,
      ),
      FossRadio(
        value: 'yearly',
        label: 'Yearly',
        description: widget.showDescriptions
            ? 'Save 16% billed annually'
            : null,
      ),
    ],
  );
}
