import 'dart:io';

import 'package:bassliner/data/pattern_editor.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/subjects.dart';

class BrowseScreenSelection {
  int group;
  int item;

  BrowseScreenSelection(this.group, this.item);
}

enum BrowseScreenMode { load, save, edit }

abstract class BrowseScreenViewModel {
  BrowseScreenSelection? selectedItem;
  String? title;
  BrowseScreenMode mode;
  final selectedDirectory = BehaviorSubject<String?>();
  final rootDirectory = BehaviorSubject<String?>();

  BrowseScreenViewModel({this.title, this.mode = BrowseScreenMode.load}) {
    _setup();
  }

  void _setup() async {
    Directory directory = await getApplicationDocumentsDirectory();
    if (Platform.isAndroid) {
      final patternDirectory = Directory('${directory.path}/Patterns');
      if (!patternDirectory.existsSync()) {
        patternDirectory.createSync();
      }
      directory = patternDirectory;
    }
    rootDirectory.add(directory.path);
    selectedDirectory.add(directory.path);
  }

  void selectPattern(int group, int item);
  void selectPath(String path) {}
  void selectDirectory(String? path) {
    selectedDirectory.add(path);
  }

  void saveAsNew(String path, String name) {}
}

class BrowseScreenLoadViewModel extends BrowseScreenViewModel {
  final PatternEditor patternEditor;

  BrowseScreenLoadViewModel({super.title, required this.patternEditor})
      : super(mode: BrowseScreenMode.load);

  @override
  void selectPath(String path) {
    patternEditor.loadCurrentFromPath(path);
  }

  @override
  void selectPattern(int group, int item) {
    patternEditor.selectPattern(group, item);
  }
}

// MARK: -

class BrowseScreenSaveViewModel extends BrowseScreenViewModel {
  final PatternEditor patternEditor;

  BrowseScreenSaveViewModel({super.title, required this.patternEditor})
      : super(mode: BrowseScreenMode.save);

  @override
  void selectPattern(int group, int item) {
    debugPrint('Save to $group $item');
  }

  @override
  void selectPath(String path) {
    patternEditor.saveCurrentToPath(path);
  }

  @override
  void saveAsNew(String path, String name) {
    final p = '$path/$name';
    patternEditor.saveCurrentToPath(p);
  }
}

// MARK: -

class BrowseScreenEditViewModel extends BrowseScreenViewModel {
  final PatternEditor patternEditor;

  BrowseScreenEditViewModel({super.title, required this.patternEditor})
      : super(mode: BrowseScreenMode.edit) {
    selectedItem =
        BrowseScreenSelection(patternEditor.selectedGroup, patternEditor.selectedPattern);
  }

  @override
  void selectPattern(int group, int item) {
    patternEditor.selectPattern(group, item);
  }
}
