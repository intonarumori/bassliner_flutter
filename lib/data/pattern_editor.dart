import 'dart:async';
import 'dart:io';

import 'package:bassliner/data/abl3_pattern.dart';
import 'package:bassliner/data/pattern_data.dart';
import 'package:bassliner/data/pattern_parser.dart';
import 'package:bassliner/data/td3_connection.dart';
import 'package:flutter/material.dart';

class PatternEditor extends ChangeNotifier {
  EditorPatternData _pattern = EditorPatternData.getDefault();
  EditorPatternData get pattern => _pattern;

  int selectedGroup = 0;
  int selectedPattern = 0;

  final connection = Td3Connection();

  StreamSubscription<Td3PatternData>? patternSubscription;
  StreamSubscription<bool>? connectionSubscription;

  PatternEditor() {
    patternSubscription = connection.patternStream.listen(_handlePatternReceived);
    connectionSubscription = connection.connected.listen((value) {
      _refreshCurrentPattern();
    });
  }

  void _refreshCurrentPattern() {
    if (connection.connected.value) {
      connection.requestPattern(selectedGroup, selectedPattern);
    }
  }

  void _handlePatternReceived(Td3PatternData td3PatternData) {
    final editorPatternData =
        PatternParser.convertTd3PatternDataToEditorPatternData(td3PatternData);
    _pattern = editorPatternData;

    notifyListeners();
  }

  String selectedPatternName() {
    final groupName = groupTitle(selectedGroup);
    final isA = selectedPattern < 8;
    final index = selectedPattern - (isA ? 0 : 1) * 8;
    late String patternName = '${index + 1} ${isA ? 'A' : 'B'}';
    return '$groupName / $patternName';
  }

  static String groupTitle(int group) {
    switch (group) {
      case 0:
        return 'I';
      case 1:
        return 'II';
      case 2:
        return 'III';
      default:
        return 'IV';
    }
  }

  static int convertToAABBfromABAB(int value) {
    final ab = value % 2;
    final index = (value / 2).floor();
    return ab * 8 + index;
  }

  static int convertToABABfromAABB(int value) {
    final ab = (value / 8).floor();
    final index = value - ab * 8;
    return index * 2 + ab;
  }

  void refresh() {
    connection.requestPattern(selectedGroup, selectedPattern);
  }

  void selectPattern(int group, int pattern) {
    selectedGroup = group;
    selectedPattern = pattern;
    _refreshCurrentPattern();
    notifyListeners();
  }

  void saveToPattern(int group, int pattern) {
    final td3PatternData = PatternParser.convertEditorPatternDataToTd3PatternData(this.pattern);
    connection.sendPatternData(td3PatternData, group, pattern);
  }

  void loadCurrentFromPath(String path) async {
    final data = await File(path).readAsString();
    final abl3Pattern = Abl3PatternParser.parsePattern(data);
    if (abl3Pattern != null) {
      final editorPatternData = EditorPatternData.fromAbl3Pattern(abl3Pattern);
      _pattern = editorPatternData;
      notifyListeners();
      debugPrint('ABL3 file loaded successfully.');
    }
  }

  void saveCurrentToPath(String path) {
    final abl3Pattern = pattern.toAbl3Pattern();
    final data = Abl3PatternParser.serializePattern(abl3Pattern);

    debugPrint('DATA: $data');
    final file = File(path);
    file.writeAsString(data);
  }

  // Setters

  void setTriplet(bool triplet) {
    pattern.triplets = triplet;
    notifyListeners();
    _sendChanges();
  }

  void incrementSteps(int count) {
    pattern.steps = (pattern.steps + count).clamp(1, 16);
    notifyListeners();
    _sendChanges();
  }

  void shift(int offset) {
    pattern.notes = pattern.notes.rotate(offset);
    pattern.accents = pattern.accents.rotate(offset);
    pattern.slides = pattern.slides.rotate(offset);
    pattern.gates = pattern.gates.rotate(offset);
    pattern.octaves = pattern.octaves.rotate(offset);
    notifyListeners();
    _sendChanges();
  }

  void setNotes(List<int> notes) {
    pattern.notes = notes;
    notifyListeners();
    _sendChanges();
  }

  void setGates(List<bool> gates) {
    pattern.gates = gates;
    notifyListeners();
    _sendChanges();
  }

  void setOctaves(List<int> octaves) {
    pattern.octaves = octaves;
    notifyListeners();
    _sendChanges();
  }

  void setSlides(List<bool> slides) {
    pattern.slides = slides;
    notifyListeners();
    _sendChanges();
  }

  void setAccents(List<bool> accents) {
    pattern.accents = accents;
    notifyListeners();
    _sendChanges();
  }

  void _sendChanges() {
    final td3PatternData = PatternParser.convertEditorPatternDataToTd3PatternData(pattern);
    connection.sendPatternData(td3PatternData, selectedGroup, selectedPattern);
  }
}

extension ListRotation<T> on List<T> {
  List<T> rotate(int shift) {
    assert(shift.abs() < length);

    if (shift < 0) {
      return sublist(-shift, length)..addAll(sublist(0, -shift));
    } else {
      return sublist(length - shift, length)..addAll(sublist(0, length - shift));
    }
  }
}
