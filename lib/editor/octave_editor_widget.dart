import 'package:bassliner/views/iterable_extension.dart';
import 'package:bassliner/views/multi_touch_detector.dart';
import 'package:bassliner/editor/note_column.dart';
import 'package:bassliner/views/theme.dart';
import 'package:flutter/material.dart';

class OctaveEditorWidget extends StatefulWidget {
  final int rows;
  final List<int> values;
  final int enabledSteps;
  final Function(List<int> values) onChange;

  const OctaveEditorWidget({
    super.key,
    required this.values,
    required this.enabledSteps,
    this.rows = 3,
    required this.onChange,
  });

  @override
  State<OctaveEditorWidget> createState() => _OctaveEditorWidgetState();
}

class _OctaveEditorWidgetState extends State<OctaveEditorWidget> {
  final Map<int, Offset> _trackedTouches = {};

  List<int> _pitches = List<int>.filled(16, 0);

  @override
  void initState() {
    super.initState();
    _pitches = widget.values;
  }

  @override
  void didUpdateWidget(covariant OctaveEditorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.values != widget.values) {
      _pitches = widget.values;
      setState(() {});
    }
  }

  void _touchStarted(int pointer, Offset localPosition) {
    _trackedTouches[pointer] = localPosition;
    _updateSelection();
  }

  void _touchMoved(int pointer, Offset localPosition) {
    _trackedTouches[pointer] = localPosition;
    _updateSelection();
  }

  void _touchEnded(int pointer, Offset localPosition) {
    _trackedTouches.remove(pointer);
    _updateSelection();
  }

  void _updateSelection() {
    final size = context.size ?? const Size(200, 200);
    final columnWidth = size.width / _pitches.length.toDouble();
    final rowHeight = size.height / widget.rows;

    _trackedTouches.forEach((key, value) {
      final column = (value.dx / columnWidth).floor().clamp(0, _pitches.length - 1);
      final row = (value.dy / rowHeight + 1).floor().clamp(0, widget.rows);
      _pitches[column] = widget.rows - row;
      widget.onChange(_pitches);
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).basslinerTheme;
    return MultiTouchDetector(
      onTouchStarted: _touchStarted,
      onTouchMoved: _touchMoved,
      onTouchEnded: _touchEnded,
      onTouchCancelled: _touchEnded,
      child: Row(
        children: _pitches
            .asMap()
            .entries
            .map<Widget>((e) {
              final enabled = e.key < widget.enabledSteps;
              return Expanded(
                child: NoteColumn(
                  selectedIndex: e.value,
                  notes: widget.rows,
                  colors: enabled
                      ? [theme.whiteKeyColor, theme.blackKeyColor, theme.whiteKeyColor]
                      : [
                          theme.disabledWhiteKeyColor,
                          theme.disabledBlackKeyColor,
                          theme.disabledWhiteKeyColor
                        ],
                  selectionColor: enabled ? theme.selectionColor : theme.disabledSelectionColor,
                  icons: const [
                    'assets/OctaveDownIcon.svg',
                    'assets/OctaveMiddleIcon.svg',
                    'assets/OctaveUpIcon.svg'
                  ],
                  onChange: (selectedIndex) => debugPrint('change'),
                ),
              );
            })
            .intersperse(() => const SizedBox(width: 2))
            .toList(),
      ),
    );
  }
}
