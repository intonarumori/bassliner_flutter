import 'package:bassliner/browser/browser_screen.dart';
import 'package:bassliner/browser/browser_viewmodels.dart';
import 'package:bassliner/data/pattern_editor.dart';
import 'package:bassliner/editor/multiselect_row_widget.dart';
import 'package:bassliner/editor/note_column.dart';
import 'package:bassliner/editor/note_editor_widget.dart';
import 'package:bassliner/editor/octave_editor_widget.dart';
import 'package:bassliner/views/bordered_button.dart';
import 'package:bassliner/views/pianokeys.dart';
import 'package:bassliner/views/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class EditorScreen extends StatefulWidget {
  final Function() onToggleTheme;
  const EditorScreen({super.key, required this.onToggleTheme});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  void _navigateToSave() {
    final patternEditor = Provider.of<PatternEditor>(context, listen: false);
    Navigator.of(context).push(
      BrowserRoute(
        onToggleTheme: widget.onToggleTheme,
        viewModel: BrowseScreenSaveViewModel(
          title: 'Select a pattern to save to',
          patternEditor: patternEditor,
        ),
      ),
    );
  }

  void _navigateToEdit() {
    final patternEditor = Provider.of<PatternEditor>(context, listen: false);
    Navigator.of(context).push(
      BrowserRoute(
        onToggleTheme: widget.onToggleTheme,
        viewModel: BrowseScreenEditViewModel(
          title: 'Select TD-3 pattern to edit',
          patternEditor: patternEditor,
        ),
      ),
    );
  }

  void _navigateToLoad() {
    final patternEditor = Provider.of<PatternEditor>(context, listen: false);
    Navigator.of(context).push(
      BrowserRoute(
        onToggleTheme: widget.onToggleTheme,
        viewModel: BrowseScreenLoadViewModel(
          title: 'Select a pattern to load from',
          patternEditor: patternEditor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const double headerWidth = 100;

    final theme = Theme.of(context).basslinerTheme;
    final size = MediaQuery.of(context).size;

    final EdgeInsets margins = size.width > 1000
        ? const EdgeInsets.fromLTRB(30, 30, 30, 40)
        : const EdgeInsets.fromLTRB(10, 10, 10, 30);
    final double unitHeight = (size.height / 20).floorToDouble();
    final double rem = size.height > 500 ? 10 : 8;
    final double headerHeight = rem * 6;

    return Container(
      padding: margins,
      color: theme.backgroundColor,
      child: Column(
        children: [
          // TOP
          SizedBox(
            height: headerHeight,
            child: Row(
              children: [
                // LOGO
                SizedBox(
                  width: headerWidth,
                  child: TextButton(
                    onPressed: widget.onToggleTheme,
                    child: SvgPicture.asset(
                      'assets/BasslineLogoOutline.svg',
                      colorFilter: ColorFilter.mode(theme.whiteKeyColor, BlendMode.srcIn),
                    ),
                  ),
                ),
                const SizedBox(width: 5),

                // MENU + LABELS
                Expanded(
                    child: Column(
                  children: [
                    // MENU
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          BorderedButton(
                              minimumSize: const Size(50, 30),
                              icon: 'assets/QuestionMarkIcon.svg',
                              onPressed: () => debugPrint('press')),
                          const SizedBox(width: 4),
                          Consumer<PatternEditor>(builder: (context, value, child) {
                            return BorderedButton(
                              minimumSize: const Size(50, 30),
                              icon: 'assets/RefreshIcon.svg',
                              onPressed: () => value.refresh(),
                            );
                          }),
                          const SizedBox(width: 4),
                          BorderedButton(text: 'Load', onPressed: _navigateToLoad),
                          const SizedBox(width: 4),
                          Consumer<PatternEditor>(builder: (context, value, child) {
                            return BorderedButton(
                                text: 'Edit ${value.selectedPatternName()}',
                                onPressed: _navigateToEdit);
                          }),
                          const SizedBox(width: 4),
                          Consumer<PatternEditor>(builder: (context, value, child) {
                            return BorderedButton(text: 'Save', onPressed: _navigateToSave);
                          }),
                          const Spacer(),
                          Consumer<PatternEditor>(builder: (context, value, child) {
                            return ToggleButton(
                                text: 'Triplet',
                                selected: value.pattern.triplets,
                                onToggle: (bool selected) => value.setTriplet(selected));
                          }),
                          const SizedBox(width: 4),
                          Consumer<PatternEditor>(builder: (context, editor, child) {
                            return Container(
                              width: 100,
                              decoration: BoxDecoration(
                                color: theme.whiteKeyColor,
                                borderRadius: const BorderRadius.all(Radius.circular(5)),
                              ),
                              child: Stack(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: BorderedButton(
                                          text: '-',
                                          onPressed: () => editor.incrementSteps(-1),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: BorderedButton(
                                          text: '+',
                                          onPressed: () => editor.incrementSteps(1),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Center(
                                    child: Text(
                                      '${editor.pattern.steps}',
                                      textAlign: TextAlign.center,
                                    ),
                                  )
                                ],
                              ),
                            );
                          }),
                          const SizedBox(width: 4),
                          Consumer<PatternEditor>(builder: (context, value, child) {
                            return BorderedButton(
                              icon: 'assets/RotateLeftIcon.svg',
                              onPressed: () => value.shift(-1),
                            );
                          }),
                          const SizedBox(width: 4),
                          Consumer<PatternEditor>(builder: (context, value, child) {
                            return BorderedButton(
                              icon: 'assets/RotateRightIcon.svg',
                              onPressed: () => value.shift(1),
                            );
                          }),
                        ],
                      ),
                    ),
                    SizedBox(height: rem * 0.5),

                    // LABELS
                    SizedBox(
                      height: rem * 2,
                      child: Row(
                        children: List.generate(16, (index) => index)
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
                ))
              ],
            ),
          ),
          SizedBox(height: rem * 0.5),
          Expanded(
            child: Row(
              children: [
                SizedBox(
                  width: headerWidth,
                  child: NoteColumn(
                    colors: theme.keyColors,
                    selectionColor: theme.selectionColor,
                    labels: PianoKeys.labels,
                    onChange: (selectedIndex) => debugPrint('change'),
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(child: Consumer<PatternEditor>(builder: (context, value, child) {
                  return RepaintBoundary(
                    child: NoteEditorWidget(
                      enabledSteps: value.pattern.steps,
                      notes: value.pattern.notes,
                      onChange: (notes) => value.setNotes(notes),
                    ),
                  );
                }))
              ],
            ),
          ),
          SizedBox(height: rem * 0.5),
          SizedBox(
            height: unitHeight * 3,
            child: Row(
              children: [
                SizedBox(
                  width: headerWidth,
                  child: NoteColumn(
                    selectionColor: theme.selectionColor,
                    colors: [theme.whiteKeyColor, theme.blackKeyColor, theme.whiteKeyColor],
                    labels: const ['-1', 'Octave', '+1'],
                    notes: 3,
                    onChange: (selectedIndex) => debugPrint('changed'),
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(child: Consumer<PatternEditor>(builder: (context, value, child) {
                  return OctaveEditorWidget(
                    enabledSteps: value.pattern.steps,
                    values: value.pattern.octaves,
                    onChange: (values) => value.setOctaves(values),
                  );
                })),
              ],
            ),
          ),
          SizedBox(height: rem),
          SizedBox(
            height: unitHeight * 2,
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      SizedBox(
                        width: headerWidth,
                        child: NoteItem(
                          color: theme.selectionColor,
                          backgroundColor: theme.whiteKeyColor,
                          text: 'Slide / Tie',
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Consumer<PatternEditor>(builder: (context, value, child) {
                          return MultiSelectRowWidget(
                            enabledSteps: value.pattern.steps,
                            values: value.pattern.slides,
                            itemBuilder: (index, selected, enabled) => NoteItem(
                              color: enabled ? theme.selectionColor : theme.disabledSelectionColor,
                              backgroundColor:
                                  enabled ? theme.whiteKeyColor : theme.disabledWhiteKeyColor,
                              icon: selected ? 'assets/StepSelectionIcon.svg' : null,
                            ),
                            onChange: (values) => value.setSlides(values),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: rem * 0.5),
                Expanded(
                  child: Row(
                    children: [
                      SizedBox(
                        width: headerWidth,
                        child: NoteItem(
                          color: theme.selectionColor,
                          backgroundColor: theme.whiteKeyColor,
                          text: 'Accent',
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(child: Consumer<PatternEditor>(builder: (context, value, child) {
                        return MultiSelectRowWidget(
                          enabledSteps: value.pattern.steps,
                          values: value.pattern.accents,
                          itemBuilder: (index, selected, enabled) => NoteItem(
                            color: enabled ? theme.selectionColor : theme.disabledSelectionColor,
                            backgroundColor:
                                enabled ? theme.whiteKeyColor : theme.disabledWhiteKeyColor,
                            icon: selected ? 'assets/StepSelectionIcon.svg' : null,
                          ),
                          onChange: (values) => value.setAccents(values),
                        );
                      })),
                    ],
                  ),
                )
              ],
            ),
          ),
          SizedBox(height: rem),
          SizedBox(
            height: unitHeight,
            child: Row(
              children: [
                SizedBox(
                  width: headerWidth,
                  child: NoteItem(
                    color: theme.selectionColor,
                    backgroundColor: theme.whiteKeyColor,
                    text: 'Gate',
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Consumer<PatternEditor>(builder: (context, value, child) {
                    return MultiSelectRowWidget(
                      enabledSteps: value.pattern.steps,
                      values: value.pattern.gates,
                      itemBuilder: (index, selected, enabled) => NoteItem(
                        color: enabled ? theme.selectionColor : theme.disabledSelectionColor,
                        backgroundColor:
                            enabled ? theme.whiteKeyColor : theme.disabledWhiteKeyColor,
                        icon: selected ? 'assets/StepSelectionIcon.svg' : null,
                      ),
                      onChange: (values) => value.setGates(values),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
