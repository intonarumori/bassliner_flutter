import 'package:bassliner/views/iterable_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class NoteColumn extends StatelessWidget {
  static const double padding = 3;

  final int notes;
  final int? selectedIndex;
  final List<String>? labels;
  final List<Color> colors;
  final Color selectionColor;
  final List<String>? icons;
  final Function(int selectedIndex)? onChange;

  const NoteColumn({
    super.key,
    this.selectedIndex,
    this.notes = 13,
    this.labels,
    this.icons,
    required this.colors,
    required this.selectionColor,
    this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    final children = List.generate(notes, (index) => index).map((e) {
      final index = (notes - 1 - e).toInt();
      final selected = (notes - 1 - e) == selectedIndex;
      final icon = icons != null ? icons![index % icons!.length] : null;
      final label = labels != null ? labels![index % labels!.length] : null;

      return NoteItem(
        color: selectionColor,
        backgroundColor:
            (selected && icon == null) ? selectionColor : colors[index % colors.length],
        text: label,
        icon: selected ? icon : null,
      );
    }).toList();

    return Column(
      children: children
          .map<Widget>((e) => Expanded(child: e))
          .intersperse(() => const SizedBox(height: padding))
          .toList(),
    );
  }
}

class NoteItem extends StatelessWidget {
  final Color backgroundColor;
  final Color color;
  final String? text;
  final String? icon;
  const NoteItem({
    super.key,
    required this.color,
    required this.backgroundColor,
    this.text,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    Widget? content;
    if (text != null) {
      content = Text(
        text!,
        textAlign: TextAlign.center,
      );
    }
    if (icon != null) {
      content = SvgPicture.asset(
        icon!,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      );
    }
    final decoration = BoxDecoration(
        color: backgroundColor, borderRadius: const BorderRadius.all(Radius.circular(5)));
    if (content != null) {
      return Container(decoration: decoration, child: Center(child: content));
    } else {
      return Container(decoration: decoration);
    }
  }
}
