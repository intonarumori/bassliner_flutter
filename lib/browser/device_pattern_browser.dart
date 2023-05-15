import 'package:bassliner/browser/browser_viewmodels.dart';
import 'package:bassliner/data/pattern_editor.dart';
import 'package:bassliner/editor/note_column.dart';
import 'package:bassliner/views/iterable_extension.dart';
import 'package:bassliner/views/theme.dart';
import 'package:flutter/material.dart';

class DevicePatternBrowser extends StatefulWidget {
  final BrowseScreenViewModel viewModel;
  final Function(int group, int pattern) onSelect;
  const DevicePatternBrowser({super.key, required this.viewModel, required this.onSelect});

  @override
  State<DevicePatternBrowser> createState() => _DevicePatternBrowserState();
}

class _DevicePatternBrowserState extends State<DevicePatternBrowser> {
  void _select(int group, int item) {
    int tdItem = PatternEditor.convertToAABBfromABAB(item);
    widget.onSelect(group, tdItem);
  }

  @override
  Widget build(BuildContext context) {
    const double rowHeight = 38;

    int? selectedGroup;
    int? selectedItem;

    if (widget.viewModel.selectedItem != null) {
      selectedGroup = widget.viewModel.selectedItem!.group;
      selectedItem = PatternEditor.convertToABABfromAABB(widget.viewModel.selectedItem!.item);
    }
    final theme = Theme.of(context).basslinerTheme;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).basslinerTheme.disabledBlackKeyColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const SizedBox(width: 105),
              // LABELS
              Expanded(
                child: Row(
                  children: List.generate(8, (index) => index)
                      .map((e) => Expanded(
                              child: Text(
                            '${e + 1}',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: theme.whiteKeyColor),
                          )))
                      .toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Row(
              children: [
                SizedBox(
                  width: 100,
                  child: Column(
                    children: List.generate(4, (index) => index)
                        .map<Widget>(
                          (e) => SizedBox(
                            height: rowHeight,
                            child: NoteItem(
                              text: PatternEditor.groupTitle(e),
                              color: theme.selectionColor,
                              backgroundColor: theme.whiteKeyColor,
                            ),
                          ),
                        )
                        .intersperse(() => const SizedBox(height: 3))
                        .toList(),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    children: List.generate(4, (index) => index)
                        .map<Widget>((f) => SizedBox(
                              height: rowHeight,
                              child: Row(
                                children: List.generate(16, (index) => index)
                                    .map<Widget>(
                                      (e) {
                                        final selected = selectedGroup == f && selectedItem == e;
                                        return Expanded(
                                          child: GestureDetector(
                                            onTap: () => _select(f, e),
                                            child: NoteItem(
                                              text: e % 2 == 1 ? 'B' : 'A',
                                              backgroundColor: selected
                                                  ? theme.selectionColor
                                                  : theme.whiteKeyColor,
                                              color: theme.selectionColor,
                                            ),
                                          ),
                                        );
                                      },
                                    )
                                    .intersperse(() => const SizedBox(width: 3))
                                    .toList(),
                              ),
                            ))
                        .intersperse(() => const SizedBox(height: 3))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
