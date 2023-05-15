import 'package:flutter/cupertino.dart';

class MultiTouchDetector extends StatefulWidget {
  final Widget child;
  final Function(int pointer, Offset localPosition)? onTouchStarted;
  final Function(int pointer, Offset localPosition)? onTouchMoved;
  final Function(int pointer, Offset localPosition)? onTouchEnded;
  final Function(int pointer, Offset localPosition)? onTouchCancelled;

  const MultiTouchDetector({
    super.key,
    required this.child,
    this.onTouchStarted,
    this.onTouchMoved,
    this.onTouchEnded,
    this.onTouchCancelled,
  });

  @override
  State<MultiTouchDetector> createState() => _MultiTouchDetectorState();
}

// MARK: -

class _MultiTouchDetectorState extends State<MultiTouchDetector> {
  void _pointerDown(PointerEvent event) {
    widget.onTouchStarted?.call(event.pointer, event.localPosition);
  }

  void _pointerMove(PointerMoveEvent event) {
    widget.onTouchMoved?.call(event.pointer, event.localPosition);
  }

  void _pointerUp(PointerUpEvent event) {
    widget.onTouchEnded?.call(event.pointer, event.localPosition);
  }

  void _pointerCancel(PointerCancelEvent event) {
    widget.onTouchCancelled?.call(event.pointer, event.localPosition);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerCancel: (event) => _pointerCancel(event),
      onPointerDown: (event) => _pointerDown(event),
      onPointerUp: (event) => _pointerUp(event),
      onPointerMove: (event) => _pointerMove(event),
      behavior: HitTestBehavior.opaque,
      child: widget.child,
    );
  }
}
