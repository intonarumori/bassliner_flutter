import 'package:bassliner/data/abl3_pattern.dart';
import 'package:bassliner/data/pattern_parser.dart';
import 'package:flutter/foundation.dart';

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

  factory EditorPatternData.fromAbl3Pattern(Abl3Pattern abl3Pattern) {
    // TD-3 range is C1-C4 when in sequencer mode
    // Note: C1, C2, C3, C4
    // MIDI: 24, 36, 48, 60
    // Hz:   32  65  131 262

    // Bassliner format: pitch 0 = C2
    // ABL3 format: pitch 0 = C3

    final octaves = List.filled(16, 0);
    final pitches = List.filled(16, 36);
    final accents = List.filled(16, false);
    final gates = List.filled(16, true);
    final slides = List.filled(16, false);

    abl3Pattern.steps.asMap().entries.forEach((element) {
      final index = element.key;
      int pitch = element.value.pitch + 12;
      final up = element.value.up;
      final down = element.value.down;

      int octave = (up && !down) ? 2 : (!up && down ? 0 : 1);

      // abl3 pitches have 0 at midi pitch 48
      // final midiPitch = pitch + 48;
      // // the actual midi pitch of the note
      int midiPitch = pitch + 36 + (up ? 1 : 0) * 12 - (down ? 1 : 0) * 12;

      // // gracefully shift notes that are out of range of the the TD-3 sequencer (C1-C4).
      // This might happen when the pattern comes from the ABL3 VST where higher notes are allowed
      while (midiPitch > PatternParser.maxPitch) {
        pitch -= 12;
        midiPitch -= 12;
      }
      while (midiPitch < 24) {
        pitch += 12;
        midiPitch += 12;
      }

      while (pitch > 12 && octave > 0) {
        pitch -= 12;
        octave -= 1;
      }

      // Prefer octave switch compared to top C
      if (pitch == 12 && octave > 0) {
        pitch -= 12;
        octave -= 1;
      }

      if (pitch < 0 || pitch > 12) {
        debugPrint('Could not match notes from ABL3 pattern.');
      }

      pitches[index] = pitch;
      octaves[index] = octave;
      accents[index] = element.value.accent;
      slides[index] = element.value.slide;
      gates[index] = element.value.gate;
    });

    return EditorPatternData(
      notes: pitches,
      octaves: octaves,
      accents: accents,
      slides: slides,
      gates: gates,
      triplets: abl3Pattern.parameters.triplet > 0,
      steps: abl3Pattern.steps.length,
    );
  }

  Abl3Pattern toAbl3Pattern() {
    List<Abl3PatternStep> steps = [];
    for (int i = 0; i < this.steps; i++) {
      int pitch = notes[i] - 12;
      int octave = octaves[i];
      while (pitch < 0 && octave < 2) {
        pitch += 12;
        octave += 1;
      }
      final up = octave == 2;
      final down = octave == 0;
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
    final abl3Pattern = Abl3Pattern(
      parameters: Abl3SynthParameters(triplet: triplets ? 1 : 0, shuffle: 0),
      steps: steps,
    );

    return abl3Pattern;
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

  @override
  bool operator ==(Object other) =>
      other is EditorPatternData &&
      other.runtimeType == runtimeType &&
      listEquals(other.gates, gates) &&
      listEquals(other.accents, accents) &&
      listEquals(other.slides, slides) &&
      listEquals(other.octaves, octaves) &&
      listEquals(other.notes, notes) &&
      other.triplets == triplets &&
      other.steps == steps;

  @override
  int get hashCode =>
      gates.hashCode ^
      accents.hashCode ^
      slides.hashCode ^
      octaves.hashCode ^
      notes.hashCode ^
      triplets.hashCode ^
      steps.hashCode;
}
