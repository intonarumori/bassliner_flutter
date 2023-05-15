import 'dart:math';

import 'package:bassliner/data/abl3_pattern.dart';

class EditorPatternData {
  List<int> notes;
  List<bool> accents;
  List<bool> slides;
  List<bool> gates;
  List<int> octaves;
  bool triplets;
  int steps;

  EditorPatternData({
    required this.notes,
    required this.accents,
    required this.slides,
    required this.gates,
    required this.octaves,
    required this.triplets,
    required this.steps,
  })  : assert(notes.length == accents.length),
        assert(notes.length == slides.length),
        assert(notes.length == gates.length),
        assert(notes.length == octaves.length);

  factory EditorPatternData.getDefault() {
    return EditorPatternData(
      notes: List.filled(16, 0),
      accents: List.filled(16, false),
      slides: List.filled(16, false),
      gates: List.filled(16, true),
      octaves: List.filled(16, 1),
      triplets: false,
      steps: 16,
    );
  }

  static EditorPatternData fromAbl3Pattern(Abl3Pattern abl3Pattern) {
    final rawPitches = abl3Pattern.steps
        .map((e) => e.pitch + (e.down ? 1 : 0) * -12 + (e.up ? 1 : 0) * 12)
        .map((e) => min(e, 48))
        .toList();
    final octaves = rawPitches
        .map((e) => e < 24
            ? -1
            : e >= 36
                ? 1
                : 0)
        .toList();

    return EditorPatternData(
      notes: abl3Pattern.steps.map((e) => e.pitch % 12).toList(),
      octaves: octaves,
      accents: abl3Pattern.steps.map((e) => e.accent).toList(),
      slides: abl3Pattern.steps.map((e) => e.slide).toList(),
      gates: abl3Pattern.steps.map((e) => e.gate).toList(),
      triplets: abl3Pattern.parameters.triplet > 0,
      steps: abl3Pattern.steps.length,
    );
  }

  Abl3Pattern toAbl3Pattern() {
    List<Abl3PatternStep> steps = [];
    for (int i = 0; i < this.steps; i++) {
      final pitch = notes[i];
      final up = octaves[i] == 2;
      final down = octaves[i] == 0;
      final step = Abl3PatternStep(
        accent: accents[i],
        slide: slides[i],
        gate: gates[i],
        up: up,
        down: down,
        pitch: pitch,
      );
      steps.add(step);
    }
    return Abl3Pattern(
      parameters: Abl3SynthParameters(triplet: triplets ? 1 : 0, shuffle: 0),
      steps: steps,
    );
  }

  @override
  String toString() {
    String str = '[PatternData]\n';
    for (int i = 0; i < notes.length; i++) {
      str +=
          '  [Step $i] G:${gates[i] ? '1' : '0'} N:${notes[i]} O:${octaves[i]} A:${accents[i] ? '1' : '0'} S:${slides[i] ? '1' : '0'}\n';
    }

    return str;
  }
}
