import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:rxdart/subjects.dart';
import 'package:watcher/watcher.dart';

class DirectoryBrowser extends ChangeNotifier {
  late DirectoryWatcher watcher;
  final directories = BehaviorSubject<List<Directory>>.seeded([]);
  late final Directory directory;

  StreamSubscription<WatchEvent>? subscription;

  DirectoryBrowser(String path) {
    directory = Directory(path);
    watcher = DirectoryWatcher(path);
    subscription = watcher.events.listen((event) {
      _reload();
    });
    _reload();
  }

  void _reload() async {
    final files = directory.listSync();
    List<Directory> directories = files.whereType<Directory>().toList();
    directories.sort((a, b) => a.name.compareTo(b.name));
    directories = directories.where((element) => !element.name.startsWith('.')).toList();
    this.directories.add(directories);
    notifyListeners();
  }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }
}

class FileBrowser extends ChangeNotifier {
  late DirectoryWatcher watcher;
  final files = BehaviorSubject<List<File>>.seeded([]);
  late final Directory directory;

  StreamSubscription<WatchEvent>? subscription;

  FileBrowser(String path) {
    directory = Directory(path);
    watcher = DirectoryWatcher(path);
    subscription = watcher.events.listen((event) {
      _reload();
    });
    _reload();
  }

  void _reload() {
    final entries = directory.listSync();
    final files = entries.whereType<File>().toList();
    files.sort((a, b) => a.name.compareTo(b.name));
    this.files.add(files);
    notifyListeners();
  }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }
}

extension DirectoryConvenience on FileSystemEntity {
  String get name => path.split('/').last;
}
