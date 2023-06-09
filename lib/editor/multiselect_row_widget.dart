import 'package:bassliner/views/iterable_extension.dart';
import 'package:bassliner/views/multi_touch_detector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MultiSelectRowWidget extends StatefulWidget {
  final List<bool> values;
  final int enabledSteps;
  final Widget Function(int index, bool selected, bool enabled) itemBuilder;
  final Function(List<bool> values) onChange;

  const MultiSelectRowWidget({
    super.key,
    required this.values,
    required this.itemBuilder,
    required this.onChange,
    required this.enabledSteps,
  });

  @override
  State<MultiSelectRowWidget> createState() => _MultiSelectRowWidgetState();
}

class _MultiSelectRowWidgetState extends State<MultiSelectRowWidget> {
  late List<bool> values;
  final Map<int /* pointer */, int /* step index */ > _trackedTouches = {};

  @override
  void initState() {
    values = widget.values;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant MultiSelectRowWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(widget.values, oldWidget.values)) {
      values = widget.values;
      setState(() {});
    }
  }

  void _touchStarted(int pointer, Offset localPosition) {
    debugPrint("Touch started");
    final index = _stepIndexForPosition(localPosition);
    if (index != null) {
      _trackedTouches[pointer] = index;
      values[index] = !values[index];
      widget.onChange(values);
    }
    setState(() {});
  }

  void _touchMoved(int pointer, Offset localPosition) {
    final index = _stepIndexForPosition(localPosition);
    if (_trackedTouches[pointer] != index) {
      if (index != null) {
        _trackedTouches[pointer] = index;
        values[index] = !values[index];
        widget.onChange(values);
      } else {
        _trackedTouches[pointer] = -1;
      }
    }
    setState(() {});
  }

  void _touchEnded(int pointer, Offset localPosition) {}

  int? _stepIndexForPosition(Offset offset) {
    final size = context.size ?? const Size(200, 200);
    if (offset.dy < 0 || offset.dy > size.height) {
      return null;
    }
    final index = (offset.dx / size.width * values.length).floor();
    if (index < 0 || index > values.length - 1) {
      return null;
    }
    return index;
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('Rebuilt multi touch row $this');
    return MultiTouchDetector(
      onTouchStarted: _touchStarted,
      onTouchMoved: _touchMoved,
      onTouchEnded: _touchEnded,
      onTouchCancelled: _touchEnded,
      child: RepaintBoundary(
        child: Row(
          children: values
              .asMap()
              .entries
              .map<Widget>(
                (e) => Expanded(
                  child: widget.itemBuilder(e.key, e.value, e.key < widget.enabledSteps),
                ),
              )
              .intersperse(() => const SizedBox(width: 2))
              .toList(),
        ),
      ),
    );
  }
}
