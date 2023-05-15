import 'dart:io';

import 'package:bassliner/browser/browser_viewmodels.dart';
import 'package:bassliner/browser/textfield_popup.dart';
import 'package:bassliner/utilities/file_browser.dart';
import 'package:bassliner/views/bordered_button.dart';
import 'package:bassliner/views/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MobileFileBrowser extends StatefulWidget {
  final BrowseScreenViewModel viewModel;
  const MobileFileBrowser({super.key, required this.viewModel});

  @override
  State<MobileFileBrowser> createState() => _MobileFileBrowserState();
}

class _MobileFileBrowserState extends State<MobileFileBrowser> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).basslinerTheme;
    final borderedButtonTheme =
        BorderedButtonTheme(backgroundColor: theme.blackKeyColor, textColor: theme.backgroundColor);

    return SizedBox(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).basslinerTheme.disabledBlackKeyColor,
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            width: 300,
            child: Column(
              children: [
                SizedBox(
                  height: 30,
                  child: Stack(
                    children: [
                      Center(
                        child: Text('Folders', style: TextStyle(color: theme.whiteKeyColor)),
                      ),
                      Row(
                        children: [
                          // BorderedButton(
                          //   icon: 'assets/FolderIcon.svg',
                          //   insets: const EdgeInsets.all(7),
                          //   minimumSize: const Size(50, 30),
                          //   shrinkWrap: true,
                          //   theme: borderedButtonTheme,
                          //   onPressed: () => debugPrint('new folder'),
                          // ),
                          const Spacer(),
                          if (widget.viewModel.mode == BrowseScreenMode.save) ...[
                            BorderedButton(
                              icon: 'assets/PlusIcon.svg',
                              insets: const EdgeInsets.all(7),
                              minimumSize: const Size(50, 30),
                              shrinkWrap: true,
                              theme: borderedButtonTheme,
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => TextFieldPopup(
                                    title: 'Create Folder',
                                    initialText:
                                        'Project ${DateFormat('yyyy-MM-dd').format(DateTime.now())}',
                                    cancelTitle: 'Cancel',
                                    confirmTitle: 'Create',
                                    onCancel: () => {},
                                    onConfirmed: (text) {
                                      widget.viewModel.createFolder(text);
                                    },
                                  ),
                                );
                              },
                            ),
                          ]
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: StreamBuilder(
                    stream: widget.viewModel.rootDirectory,
                    builder: (context, snapshot) => snapshot.hasData
                        ? _DirectoryPanel(
                            path: snapshot.data!,
                            onPathSelect: (path) => widget.viewModel.selectDirectory(path),
                          )
                        : Container(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).basslinerTheme.disabledBlackKeyColor,
                borderRadius: const BorderRadius.all(Radius.circular(10)),
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: 30,
                    child: Stack(
                      children: [
                        Center(
                          child: Text('Patterns', style: TextStyle(color: theme.whiteKeyColor)),
                        ),
                        Row(
                          children: [
                            const Spacer(),
                            if (widget.viewModel.mode == BrowseScreenMode.save) ...[
                              BorderedButton(
                                text: 'Save as new',
                                theme: borderedButtonTheme,
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => TextFieldPopup(
                                      title: 'Save as new pattern',
                                      initialText: 'Pattern 1',
                                      cancelTitle: 'Cancel',
                                      confirmTitle: 'Confirm',
                                      onCancel: () => {},
                                      onConfirmed: (text) {
                                        widget.viewModel.saveAsNew(
                                            widget.viewModel.selectedDirectory.value!, text);
                                      },
                                    ),
                                  );
                                },
                              ),
                            ],
                          ],
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: StreamBuilder(
                      stream: widget.viewModel.selectedDirectory,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return _PatternsPanel(
                            path: snapshot.data!,
                            onItemSelected: (path) {
                              if (widget.viewModel.mode == BrowseScreenMode.save) {
                                showDialog(
                                  context: context,
                                  builder: (context) => CupertinoAlertDialog(
                                    title: Container(
                                        padding: const EdgeInsets.only(bottom: 10),
                                        child: const Text('Overwrite Pattern')),
                                    content: const Text(
                                        'Saving the pattern to the selected file will overwrite the existing content.'),
                                    actions: [
                                      CupertinoDialogAction(
                                        onPressed: () => Navigator.of(context).pop(),
                                        child: const Text('Cancel'),
                                      ),
                                      CupertinoDialogAction(
                                        isDestructiveAction: true,
                                        onPressed: () {
                                          widget.viewModel.selectPath(path);
                                          Navigator.of(context).pop();
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('Overwrite'),
                                      ),
                                    ],
                                  ),
                                );
                              } else {
                                widget.viewModel.selectPath(path);
                                Navigator.of(context).pop();
                              }
                            },
                          );
                        } else {
                          return Container();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// MARK: -

class _DirectoryPanel extends StatefulWidget {
  final String path;
  final Function(String path) onPathSelect;

  const _DirectoryPanel({required this.path, required this.onPathSelect});

  @override
  State<_DirectoryPanel> createState() => _DirectoryPanelState();
}

class _DirectoryPanelState extends State<_DirectoryPanel> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DirectoryBrowser(widget.path),
      builder: (context, child) => Consumer<DirectoryBrowser>(
        builder: (context, value, child) {
          return StreamBuilder(
            stream: value.directories,
            builder: (context, snapshot) {
              final directories = [Directory(widget.path)] + (snapshot.data ?? []);
              return ListView.separated(
                padding: EdgeInsets.zero,
                itemBuilder: (context, index) => _FolderItemView(
                  text: directories[index].name,
                  selected: index == _selectedIndex,
                  onPressed: () {
                    setState(() {
                      _selectedIndex = index;
                    });
                    widget.onPathSelect(directories[index].path);
                  },
                ),
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemCount: directories.length,
              );
            },
          );
        },
      ),
    );
  }
}

class _PatternsPanel extends StatefulWidget {
  final String path;
  final Function(String path) onItemSelected;
  const _PatternsPanel({required this.path, required this.onItemSelected});

  @override
  State<_PatternsPanel> createState() => _PatternsPanelState();
}

class _PatternsPanelState extends State<_PatternsPanel> {
  @override
  void didUpdateWidget(covariant _PatternsPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.path != oldWidget.path) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final columns = size.width < 800 ? 2 : 4;

    return ChangeNotifierProvider(
      key: Key(widget.path),
      create: (context) => FileBrowser(widget.path),
      builder: (context, child) {
        return Consumer<FileBrowser>(builder: (context, value, child) {
          return StreamBuilder(
            stream: value.files,
            builder: (context, snapshot) {
              final files = snapshot.data ?? [];
              return GridView.count(
                padding: EdgeInsets.zero,
                crossAxisCount: columns,
                childAspectRatio: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                children: files
                    .map<Widget>(
                      (e) => InkWell(
                        onTap: () => widget.onItemSelected(e.path),
                        child: _GridItemView(text: e.name, selected: false),
                      ),
                    )
                    .toList(),
              );
            },
          );
        });
      },
    );
  }
}

class _GridItemView extends StatelessWidget {
  final String text;
  final bool selected;

  const _GridItemView({required this.text, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(5)),
        color: selected
            ? Theme.of(context).basslinerTheme.selectionColor
            : Theme.of(context).basslinerTheme.disabledWhiteKeyColor,
      ),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _FolderItemView extends StatelessWidget {
  final String text;
  final bool selected;
  final Function() onPressed;

  const _FolderItemView({required this.text, this.selected = false, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(5)),
          color: selected
              ? Theme.of(context).basslinerTheme.selectionColor
              : Theme.of(context).basslinerTheme.disabledWhiteKeyColor,
        ),
        padding: const EdgeInsets.all(10),
        height: 40,
        child: Text(text),
      ),
    );
  }
}
