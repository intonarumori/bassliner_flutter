import 'package:bassliner/views/iterable_extension.dart';
import 'package:bassliner/views/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class BorderedButtonTheme {
  final Color backgroundColor;
  final Color textColor;

  const BorderedButtonTheme({
    this.textColor = Colors.white,
    this.backgroundColor = Colors.black,
  });
}

class BorderedButton extends StatelessWidget {
  final Function() onPressed;
  final BorderedButtonTheme? theme;
  final String? text;
  final String? icon;
  final EdgeInsets insets;
  final bool shrinkWrap;
  final Size? minimumSize;

  const BorderedButton({
    super.key,
    this.text,
    this.icon,
    this.insets = const EdgeInsets.fromLTRB(10, 5, 10, 5),
    this.shrinkWrap = false,
    this.theme,
    this.minimumSize,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = this.theme ?? Theme.of(context).basslinerTheme.borderedButtonTheme;

    List<Widget> children = [];

    if (icon != null) {
      children.add(
          SvgPicture.asset(icon!, colorFilter: ColorFilter.mode(theme.textColor, BlendMode.srcIn)));
    }
    if (text != null) {
      children.add(Text(text!, style: TextStyle(color: theme.textColor)));
    }
    late Widget content;
    if (children.length == 1) {
      content = children.first;
    } else {
      content = Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: children.intersperse(() => const SizedBox(width: 7)).toList());
    }

    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        foregroundColor: theme.textColor,
        padding: insets,
        minimumSize: minimumSize ?? const Size(15, 15),
        maximumSize: minimumSize,
        tapTargetSize: shrinkWrap ? MaterialTapTargetSize.shrinkWrap : null,
        backgroundColor: theme.backgroundColor,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
      ),
      child: content,
    );
  }
}

class ToggleButtonTheme {
  final Color backgroundColor;
  final Color textColor;
  final Color selectedBackgroundColor;
  final Color selectedTextColor;

  const ToggleButtonTheme({
    this.textColor = Colors.white,
    this.backgroundColor = Colors.black,
    this.selectedTextColor = Colors.black,
    this.selectedBackgroundColor = Colors.white,
  });
}

class ToggleButton extends StatefulWidget {
  final ToggleButtonTheme? theme;
  final String? text;
  final String? icon;
  final EdgeInsets insets;
  final bool shrinkWrap;
  final bool selected;
  final Function(bool selected) onToggle;

  const ToggleButton({
    super.key,
    this.text,
    this.icon,
    this.selected = false,
    this.insets = const EdgeInsets.fromLTRB(10, 5, 10, 5),
    this.shrinkWrap = false,
    this.theme,
    required this.onToggle,
  });

  @override
  State<ToggleButton> createState() => _ToggleButtonState();
}

class _ToggleButtonState extends State<ToggleButton> {
  bool _selected = false;

  @override
  void initState() {
    _selected = widget.selected;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant ToggleButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    _selected = widget.selected;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme ?? Theme.of(context).basslinerTheme.toggleButtonTheme;
    final borderedTheme = _selected
        ? BorderedButtonTheme(
            textColor: theme.selectedTextColor, backgroundColor: theme.selectedBackgroundColor)
        : BorderedButtonTheme(textColor: theme.textColor, backgroundColor: theme.backgroundColor);

    return BorderedButton(
      text: widget.text,
      icon: widget.icon,
      theme: borderedTheme,
      onPressed: () {
        _selected = !_selected;
        widget.onToggle(_selected);
        setState(() {});
      },
    );
  }
}
