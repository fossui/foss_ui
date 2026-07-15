part of 'foss_combobox.dart';

/// The shared input, anchored popup, filtering, roving highlight, and dismiss
/// handling behind [FossAutocomplete] and [FossCombobox]. The two faces differ
/// only in the config they pass: whether rows carry a check indicator, the
/// selection predicate, and what a pick reports.
class _FossComboboxField<T> extends StatefulWidget {
  const _FossComboboxField({
    required this.options,
    required this.size,
    required this.enabled,
    required this.showIndicator,
    required this.showTrigger,
    required this.showClear,
    required this.emptyText,
    required this.filter,
    required this.isSelected,
    required this.onPick,
    this.controller,
    this.focusNode,
    this.label,
    this.hintText,
    this.errorText,
    this.startAddon,
    this.initialText,
    this.resetOnBlur = false,
    this.onTextChanged,
    this.onClear,
    this.style,
    super.key,
  });

  final List<FossComboboxItem<T>> options;
  final FossTextFieldSize size;
  final bool enabled;
  final bool showIndicator;
  final bool showTrigger;
  final bool showClear;
  final String emptyText;
  final bool Function(String label, String query) filter;
  final bool Function(T value) isSelected;
  final void Function(FossComboboxItem<T> item) onPick;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? label;
  final String? hintText;
  final String? errorText;
  final Widget? startAddon;
  final String? initialText;

  /// When true, blurring without a pick restores the field text to the
  /// selected option's label. Single-select uses this; freeform autocomplete
  /// does not.
  final bool resetOnBlur;
  final ValueChanged<String>? onTextChanged;
  final VoidCallback? onClear;
  final FossComboboxStyle? style;

  @override
  State<_FossComboboxField<T>> createState() => _FossComboboxFieldState<T>();
}

class _FossComboboxFieldState<T> extends State<_FossComboboxField<T>>
    with
        SingleTickerProviderStateMixin,
        _ComboboxPopup<T, _FossComboboxField<T>> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  TextEditingController? _ownedController;
  FocusNode? _ownedFocusNode;

  @override
  void initState() {
    super.initState();
    _controller =
        widget.controller ??
        (_ownedController = TextEditingController(text: widget.initialText));
    _focusNode = widget.focusNode ?? (_ownedFocusNode = FocusNode());
    _focusNode.addListener(_onFocusChanged);
    _controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(_FossComboboxField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _swapController(oldWidget);
    } else {
      _syncSelectedText(oldWidget);
    }
    if (widget.focusNode != oldWidget.focusNode) _swapFocusNode(oldWidget);
  }

  void _swapController(_FossComboboxField<T> oldWidget) {
    (oldWidget.controller ?? _ownedController)?.removeListener(_onTextChanged);
    _ownedController?.dispose();
    final provided = widget.controller;
    if (provided != null) {
      _ownedController = null;
      _controller = provided;
    } else {
      _controller = _ownedController = TextEditingController(
        text: oldWidget.controller?.text ?? widget.initialText,
      );
    }
    _controller.addListener(_onTextChanged);
  }

  // Reflect an externally driven selection: when the resolved label changes and
  // we own the controller, sync the field text. Skipped when it already
  // matches, so a local pick never reclobbers what it just wrote.
  void _syncSelectedText(_FossComboboxField<T> oldWidget) {
    if (widget.controller != null) return;
    if (widget.initialText == oldWidget.initialText) return;
    if (widget.initialText == _controller.text) return;
    final text = widget.initialText ?? '';
    _controller
      ..removeListener(_onTextChanged)
      ..text = text
      ..selection = TextSelection.collapsed(offset: text.length)
      ..addListener(_onTextChanged);
  }

  void _swapFocusNode(_FossComboboxField<T> oldWidget) {
    (oldWidget.focusNode ?? _ownedFocusNode)?.removeListener(_onFocusChanged);
    _ownedFocusNode?.dispose();
    final provided = widget.focusNode;
    if (provided != null) {
      _ownedFocusNode = null;
      _focusNode = provided;
    } else {
      _focusNode = _ownedFocusNode = FocusNode();
    }
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _controller.removeListener(_onTextChanged);
    _ownedController?.dispose();
    _ownedFocusNode?.dispose();
    super.dispose();
  }

  @override
  bool get popupEnabled => widget.enabled;

  // Maps the combobox overrides onto the embedded field so the input box honors
  // the fill, border, radius, text, and shadow, not just the popup.
  FossTextFieldStyle? get _fieldStyle {
    final s = widget.style;
    if (s == null) return null;
    return FossTextFieldStyle(
      backgroundColor: s.backgroundColor,
      borderColor: s.borderColor,
      borderRadius: s.borderRadius,
      textStyle: s.textStyle,
      shadow: s.shadow,
    );
  }

  // The label of the committed selection, or null when nothing is selected.
  // Autocomplete never selects, so this stays null there.
  String? get _selectedLabel {
    for (final o in widget.options) {
      if (widget.isSelected(o.value)) return o.label;
    }
    return null;
  }

  @override
  List<FossComboboxItem<T>> get filteredOptions {
    final query = _controller.text;
    // A pick writes the selected label into the field, so on reopen the query
    // equals the selection; treat that as no query rather than self-filtering
    // to the one chosen row.
    if (query.isEmpty || query == _selectedLabel) return widget.options;
    return [
      for (final o in widget.options)
        if (widget.filter(o.label, query)) o,
    ];
  }

  @override
  int initialHighlight() {
    final options = filteredOptions;
    final selected = options.indexWhere(
      (o) => o.enabled && widget.isSelected(o.value),
    );
    if (selected != -1) return selected;
    return _firstEnabled(options);
  }

  @override
  void onActivate(FossComboboxItem<T> item) => _pick(item);

  void _onFocusChanged() {
    if (_focusNode.hasFocus) {
      _openPopup();
    } else {
      _closePopup();
      _restoreSelectedText();
    }
  }

  // On blur without a pick, a single-select field snaps its text back to the
  // committed selection (or empty), so stray typing never lingers as the value.
  void _restoreSelectedText() {
    if (!widget.resetOnBlur) return;
    final selected = widget.options.where((o) => widget.isSelected(o.value));
    final text = selected.isEmpty ? '' : selected.first.label;
    if (_controller.text == text) return;
    _controller
      ..removeListener(_onTextChanged)
      ..text = text
      ..selection = TextSelection.collapsed(offset: text.length)
      ..addListener(_onTextChanged);
  }

  void _onTextChanged() {
    widget.onTextChanged?.call(_controller.text);
    _resetHighlight();
  }

  void _pick(FossComboboxItem<T> item) {
    if (!item.enabled) return;
    _controller
      ..removeListener(_onTextChanged)
      ..text = item.label
      ..selection = TextSelection.collapsed(offset: item.label.length)
      ..addListener(_onTextChanged);
    widget.onPick(item);
    _closePopup();
  }

  void _clear() {
    _controller.clear();
    widget.onClear?.call();
  }

  void _toggle() {
    if (_open) {
      _closePopup();
    } else {
      _focusNode.requestFocus();
      _openPopup();
    }
  }

  @override
  Widget build(BuildContext context) {
    final v = _apply(_resolve(context.fossTheme, widget.size), widget.style);

    final field = TextFieldTapRegion(
      child: Focus(
        canRequestFocus: false,
        skipTraversal: true,
        onKeyEvent: (node, event) => _handlePopupKey(event),
        child: Semantics(
          expanded: _open,
          child: KeyedSubtree(
            key: _anchorKey,
            child: FossTextField(
              controller: _controller,
              focusNode: _focusNode,
              size: widget.size,
              label: widget.label,
              hintText: widget.hintText,
              errorText: widget.errorText,
              enabled: widget.enabled,
              leading: widget.startAddon,
              trailing: _trailing(v),
              style: _fieldStyle,
              onSubmitted: (_) => _activateHighlighted(),
            ),
          ),
        ),
      ),
    );

    return OverlayPortal(
      controller: _portal,
      overlayChildBuilder: _buildOverlay,
      child: field,
    );
  }

  Widget? _trailing(_ComboboxVisuals v) {
    final color = v.foreground.withValues(
      alpha: v.foreground.a * _affixOpacity,
    );
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final showClear =
            widget.showClear && _controller.text.isNotEmpty && widget.enabled;
        final children = <Widget>[
          if (showClear)
            _IconButton(
              size: v.iconSize,
              onTap: _clear,
              painter: CloseGlyph(color),
              label: 'Clear',
            ),
          if (widget.showTrigger && !showClear)
            _IconButton(
              size: v.iconSize,
              onTap: widget.enabled ? _toggle : null,
              painter: ChevronUpDownGlyph(color),
              label: 'Show options',
            ),
        ];
        if (children.isEmpty) return const SizedBox.shrink();
        return Row(mainAxisSize: MainAxisSize.min, children: children);
      },
    );
  }

  @override
  Widget buildPopupSurface(BuildContext context) {
    final theme = context.fossTheme;
    final v = _apply(_resolve(theme, widget.size), widget.style);
    final options = filteredOptions;
    final Widget body;
    if (options.isEmpty) {
      body = Padding(
        padding: EdgeInsets.all(theme.spacing(2)),
        child: Text(
          widget.emptyText,
          textAlign: TextAlign.center,
          style: v.textStyle.copyWith(color: v.mutedForeground),
        ),
      );
    } else {
      body = ListView(
        shrinkWrap: true,
        padding: EdgeInsets.all(theme.spacing(1)),
        children: [
          for (var i = 0; i < options.length; i++)
            _ComboRow<T>(
              item: options[i],
              theme: theme,
              visuals: v,
              showIndicator: widget.showIndicator,
              selected: widget.isSelected(options[i].value),
              highlighted: i == _highlight,
              onEnter: () => _highlightRow(i),
              onTap: () => _pick(options[i]),
            ),
        ],
      );
    }

    return _popupChrome(v, body);
  }
}

/// A single popup row: an optional check indicator, an optional icon, and the
/// label. Autocomplete rows omit the indicator column.
class _ComboRow<T> extends StatelessWidget {
  const _ComboRow({
    required this.item,
    required this.theme,
    required this.visuals,
    required this.showIndicator,
    required this.selected,
    required this.highlighted,
    required this.onEnter,
    required this.onTap,
  });

  final FossComboboxItem<T> item;
  final FossThemeData theme;
  final _ComboboxVisuals visuals;
  final bool showIndicator;
  final bool selected;
  final bool highlighted;
  final VoidCallback onEnter;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = item.enabled;
    final fill = highlighted ? visuals.highlightColor : null;
    final textColor = highlighted
        ? visuals.highlightForeground
        : visuals.foreground;

    Widget row = Padding(
      // Combobox rows carry a wider end inset to balance the indicator
      // column; the flat autocomplete row is symmetric.
      padding: EdgeInsetsDirectional.only(
        start: theme.spacing(2),
        end: showIndicator ? theme.spacing(4) : theme.spacing(2),
        top: theme.spacing(1),
        bottom: theme.spacing(1),
      ),
      child: Row(
        children: [
          if (showIndicator) ...[
            SizedBox(
              width: _indicatorColumn,
              height: _indicatorColumn,
              child: selected ? FossGlyphIcon(CheckGlyph(textColor)) : null,
            ),
            SizedBox(width: theme.spacing(2)),
          ],
          if (item.icon case final icon?) ...[
            IconTheme.merge(
              data: IconThemeData(color: textColor, size: visuals.iconSize),
              child: icon,
            ),
            SizedBox(width: theme.spacing(2)),
          ],
          Expanded(
            child: Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: visuals.textStyle.copyWith(color: textColor),
            ),
          ),
        ],
      ),
    );

    row = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: _rowMinHeight),
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: fill,
          shape: RoundedSuperellipseBorder(
            borderRadius: BorderRadius.circular(visuals.rowRadius),
          ),
        ),
        child: Align(heightFactor: 1, child: row),
      ),
    );

    if (!enabled) row = Opacity(opacity: _disabledOpacity, child: row);

    return MergeSemantics(
      child: Semantics(
        button: true,
        selected: selected,
        enabled: enabled,
        child: MouseRegion(
          cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
          onEnter: enabled ? (_) => onEnter() : null,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: enabled ? onTap : null,
            child: row,
          ),
        ),
      ),
    );
  }
}

/// A small square icon button for the trailing trigger and clear affordances,
/// carrying a [label] so assistive tech announces it as a button.
class _IconButton extends StatelessWidget {
  const _IconButton({
    required this.size,
    required this.painter,
    required this.onTap,
    required this.label,
  });

  final double size;
  final CustomPainter painter;
  final VoidCallback? onTap;
  final String label;

  @override
  Widget build(BuildContext context) {
    // The glyph keeps its small visual footprint while an OverflowBox grows the
    // hit region to the minimum touch target without inflating the field.
    // HitTestBehavior.opaque makes the whole region tappable.
    return Semantics(
      button: true,
      label: label,
      enabled: onTap != null,
      child: SizedBox.square(
        dimension: size,
        child: OverflowBox(
          maxWidth: _minHitTarget,
          maxHeight: _minHitTarget,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: MouseRegion(
              cursor: onTap == null
                  ? SystemMouseCursors.basic
                  : SystemMouseCursors.click,
              child: Center(
                child: CustomPaint(
                  size: Size.square(size),
                  painter: painter,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Positions the popup below the anchor, flipping above when there is no room,
/// and clamping its height to the viewport and the popup maximum.
class _PopupLayout extends SingleChildLayoutDelegate {
  const _PopupLayout({required this.anchor, required this.bottomInset});

  final Rect anchor;

  /// Height taken by the on-screen keyboard at the bottom of the overlay.
  final double bottomInset;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    final viewportBottom = constraints.maxHeight - bottomInset;
    final below = viewportBottom - anchor.bottom - _popupOffset;
    final above = anchor.top - _popupOffset;
    final room = (math.max(below, above) - _popupMargin).clamp(
      0.0,
      constraints.maxHeight,
    );
    // Match the anchor width, capped to the viewport minus a margin on each
    // side, so the popup keeps symmetric insets and never runs off the edge.
    final width = math.min(
      anchor.width,
      constraints.maxWidth - _popupMargin * 2,
    );
    return BoxConstraints(
      minWidth: width,
      maxWidth: width,
      maxHeight: math.min(room, _popupMaxHeight),
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final below = (size.height - bottomInset) - anchor.bottom - _popupOffset;
    final placeBelow = childSize.height <= below;
    final dy = placeBelow
        ? anchor.bottom + _popupOffset
        : anchor.top - _popupOffset - childSize.height;
    final dx = anchor.left
        .clamp(
          _popupMargin,
          math.max(_popupMargin, size.width - _popupMargin - childSize.width),
        )
        .toDouble();
    return Offset(dx, dy);
  }

  @override
  bool shouldRelayout(_PopupLayout oldDelegate) =>
      oldDelegate.anchor != anchor || oldDelegate.bottomInset != bottomInset;
}
