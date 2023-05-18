import 'package:bassliner/views/iterable_extension.dart';
import 'package:bassliner/views/multi_touch_detector.dart';
import 'package:bassliner/editor/note_column.dart';
import 'package:bassliner/views/theme.dart';
import 'package:flutter/material.dart';

class NoteEditorWidget extends StatefulWidget {
  final List<int> notes;
  final Function(List<int> notes) onChange;
  final int enabledSteps;

  const NoteEditorWidget({
    super.key,
    required this.notes,
    required this.onChange,
    required this.enabledSteps,
  });

  @override
  State<NoteEditorWidget> createState() => _NoteEditorWidgetState();
}

class _NoteEditorWidgetState extends State<NoteEditorWidget> {
  final Map<int, Offset> _trackedTouches = {};

  static const _notesPerColumn = 13;

  List<int> _pitches = List<int>.filled(16, 0);

  @override
  void initState() {
    super.initState();
    _pitches = widget.notes;
  }

  @override
  void didUpdateWidget(covariant NoteEditorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.notes != widget.notes) {
      _pitches = widget.notes;
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
    final rowHeight = size.height / _notesPerColumn;

    _trackedTouches.forEach((key, value) {
      final column = (value.dx / columnWidth).floor().clamp(0, _pitches.length - 1);
      final row = (value.dy / rowHeight + 1).floor().clamp(0, _notesPerColumn);
      _pitches[column] = _notesPerColumn - row;
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
                child: RepaintBoundary(
                  child: NoteColumn(
                    selectedIndex: e.value,
                    notes: _notesPerColumn,
                    selectionColor: enabled ? theme.selectionColor : theme.disabledSelectionColor,
                    colors: enabled ? theme.keyColors : theme.disabledKeyColors,
                  ),
                ),
              );
            })
            .intersperse(() => const SizedBox(width: 2))
            .toList(),
      ),
    );
  }
}
