import 'dart:async';
import 'dart:io';
import 'package:bassliner/data/abl3_pattern.dart';
import 'package:bassliner/data/pattern_data.dart';
import 'package:bassliner/data/pattern_parser.dart';
import 'package:bassliner/data/td3_connection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'package:rxdart/subjects.dart';
import 'package:security_scoped_resource/security_scoped_resource.dart';

class PatternEditor {
  EditorPatternData _pattern = EditorPatternData.getDefault();
  EditorPatternData get pattern => _pattern;

  int selectedGroup = 0;
  int selectedPattern = 0;

  final connection = Td3Connection();

  StreamSubscription<Td3PatternData>? patternSubscription;
  StreamSubscription<bool>? connectionSubscription;

  final triplet = BehaviorSubject<bool>.seeded(false);
  final stepCount = BehaviorSubject<int>.seeded(16);
  final notes = BehaviorSubject<List<int>>.seeded(List.generate(16, (index) => 0));
  final octaves = BehaviorSubject<List<int>>.seeded(List.generate(16, (index) => 1));
  final slides = BehaviorSubject<List<bool>>.seeded(List.generate(16, (index) => false));
  final accents = BehaviorSubject<List<bool>>.seeded(List.generate(16, (index) => false));
  final gates = BehaviorSubject<List<bool>>.seeded(List.generate(16, (index) => false));

  BehaviorSubject<bool> get isConnected => connection.connected;
  BehaviorSubject<List<MidiDevice>> get devices => connection.devices;

  // MARK:

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
    _updatePattern(editorPatternData);
  }

  void forceConnetion() {
    connection.connected.add(true);
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
  }

  void saveToPattern(int group, int pattern) {
    final td3PatternData = PatternParser.convertEditorPatternDataToTd3PatternData(this.pattern);
    connection.sendPatternData(td3PatternData, group, pattern);
  }

  Future<void> loadFromUri(Uri uri) async {
    final file = File.fromUri(uri);

    final secure = await SecurityScopedResource.instance.startAccessingSecurityScopedResource(file);
    if (secure) {
      final data = await file.readAsString();
      await _loadFromData(data);
    }
    await SecurityScopedResource.instance.stopAccessingSecurityScopedResource(file);
  }

  Future<void> loadCurrentFromPath(String path) async {
    final data = await File(path).readAsString();
    return _loadFromData(data);
  }

  Future<void> _loadFromData(String data) async {
    // Newer pattern format
    try {
      final abl3Pattern = Abl3Version9PatternParser.parsePattern(data);
      final editorPatternData = EditorPatternData.fromAbl3Pattern(abl3Pattern);
      _updatePattern(editorPatternData);
      return;
    } on Abl3ParseException {
      debugPrint('Not an ABL3 version 9 file');
    }

    // Fall back to older pattern format
    try {
      final abl3Pattern = Abl3Version16PatternParser.parsePattern(data);
      final editorPatternData = EditorPatternData.fromAbl3Pattern(abl3Pattern);
      _updatePattern(editorPatternData);
      return;
    } on Abl3ParseException {
      debugPrint('Not an ABL3 version 16 file');
    }
  }

  void saveCurrentToPath(String path) {
    final abl3Pattern = pattern.toAbl3Pattern();
    final data = Abl3Version9PatternParser.serializePattern(abl3Pattern);

    debugPrint('DATA: $data');
    final file = File(path);
    file.writeAsString(data);
  }

  // Setters

  void setTriplet(bool triplet) {
    pattern.triplets = triplet;
    this.triplet.add(triplet);
    _sendChanges();
  }

  void incrementSteps(int count) {
    pattern.steps = (pattern.steps + count).clamp(1, 16);
    _updatePattern(pattern);
    _sendChanges();
  }

  void shift(int offset) {
    setNotes(pattern.notes.rotate(offset));
    setOctaves(pattern.octaves.rotate(offset));
    setAccents(pattern.accents.rotate(offset));
    setSlides(pattern.slides.rotate(offset));
    setGates(pattern.gates.rotate(offset));
    _sendChanges();
  }

  void setNotes(List<int> notes) {
    pattern.notes = notes;
    this.notes.add(notes);
    _sendChanges();
  }

  void setGates(List<bool> gates) {
    pattern.gates = gates;
    this.gates.add(gates);
    _sendChanges();
  }

  void setOctaves(List<int> octaves) {
    pattern.octaves = octaves;
    this.octaves.add(octaves);
    _sendChanges();
  }

  void setSlides(List<bool> slides) {
    pattern.slides = slides;
    this.slides.add(slides);
    _sendChanges();
  }

  void setAccents(List<bool> accents) {
    pattern.accents = accents;
    this.accents.add(accents);
    _sendChanges();
  }

  void _sendChanges() {
    debugPrint('[PatternEditor] Sending changes to device');
    final td3PatternData = PatternParser.convertEditorPatternDataToTd3PatternData(pattern);
    connection.sendPatternData(td3PatternData, selectedGroup, selectedPattern);
  }

  void _updatePattern(EditorPatternData data) {
    _pattern = data;
    triplet.add(_pattern.triplets);
    stepCount.add(_pattern.steps);
    notes.add(_pattern.notes);
    octaves.add(_pattern.octaves);
    slides.add(_pattern.slides);
    accents.add(_pattern.accents);
    gates.add(_pattern.gates);
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
