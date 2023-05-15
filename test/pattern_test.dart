import 'package:bassliner/data/abl3_pattern.dart';
import 'package:bassliner/data/pattern_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('testDefaultPatternExport', () {
    const abl3Pattern =
        Abl3Pattern(parameters: Abl3SynthParameters(triplet: 0, shuffle: 0), steps: [
      Abl3PatternStep(pitch: 0, up: false, down: false, accent: false, slide: false, gate: true),
      Abl3PatternStep(pitch: 0, up: false, down: false, accent: false, slide: false, gate: true),
      Abl3PatternStep(pitch: 0, up: false, down: false, accent: false, slide: false, gate: true),
      Abl3PatternStep(pitch: 0, up: false, down: false, accent: false, slide: false, gate: true),
      Abl3PatternStep(pitch: 0, up: false, down: false, accent: false, slide: false, gate: true),
      Abl3PatternStep(pitch: 0, up: false, down: false, accent: false, slide: false, gate: true),
      Abl3PatternStep(pitch: 0, up: false, down: false, accent: false, slide: false, gate: true),
      Abl3PatternStep(pitch: 0, up: false, down: false, accent: false, slide: false, gate: true),
      Abl3PatternStep(pitch: 0, up: false, down: false, accent: false, slide: false, gate: true),
      Abl3PatternStep(pitch: 0, up: false, down: false, accent: false, slide: false, gate: true),
      Abl3PatternStep(pitch: 0, up: false, down: false, accent: false, slide: false, gate: true),
      Abl3PatternStep(pitch: 0, up: false, down: false, accent: false, slide: false, gate: true),
      Abl3PatternStep(pitch: 0, up: false, down: false, accent: false, slide: false, gate: true),
      Abl3PatternStep(pitch: 0, up: false, down: false, accent: false, slide: false, gate: true),
      Abl3PatternStep(pitch: 0, up: false, down: false, accent: false, slide: false, gate: true),
      Abl3PatternStep(pitch: 0, up: false, down: false, accent: false, slide: false, gate: true),
    ]);

    final editorPattern = EditorPatternData.fromAbl3Pattern(abl3Pattern);

    expect(editorPattern.octaves, List.filled(16, 0), reason: 'Octaves should match');
    expect(editorPattern.notes, List.filled(16, 0), reason: 'Notes should match');
    expect(editorPattern.gates, List.filled(16, true));
    expect(editorPattern.slides, List.filled(16, false));
    expect(editorPattern.accents, List.filled(16, false));

    final abl3PatternExport = editorPattern.toAbl3Pattern();
    expect(abl3Pattern, abl3PatternExport);
  });

  test('testEditorPatternDataConversion', () {
    final editorPatternData = EditorPatternData(
      notes: List.filled(16, 0)..[1] = 2,
      accents: List.filled(16, false)..[4] = true,
      slides: List.filled(16, false)..[5] = true,
      gates: List.filled(16, true)..[6] = false,
      octaves: List.filled(16, 0)..[7] = 1,
      triplets: false,
      steps: 16,
    );
    final abl3Pattern = editorPatternData.toAbl3Pattern();
    final editorPatternData2 = EditorPatternData.fromAbl3Pattern(abl3Pattern);

    expect(editorPatternData, editorPatternData2);
  });

  test('testOutOfRangeNotesAndGracefulAdjustments', () {
    const abl3Pattern = Abl3Pattern(
      parameters: Abl3SynthParameters(triplet: 0, shuffle: 0),
      steps: [
        Abl3PatternStep(pitch: 12, up: false, down: false, accent: false, slide: false, gate: true),
        Abl3PatternStep(pitch: 24, up: false, down: false, accent: false, slide: false, gate: true),
        Abl3PatternStep(pitch: 36, up: false, down: false, accent: false, slide: false, gate: true),
        Abl3PatternStep(pitch: 48, up: false, down: false, accent: false, slide: false, gate: true),
        Abl3PatternStep(pitch: 60, up: false, down: false, accent: false, slide: false, gate: true),
        Abl3PatternStep(pitch: 0, up: false, down: false, accent: false, slide: false, gate: true),
        Abl3PatternStep(pitch: 0, up: false, down: false, accent: false, slide: false, gate: true),
        Abl3PatternStep(pitch: 0, up: false, down: false, accent: false, slide: false, gate: true),
        Abl3PatternStep(pitch: 0, up: false, down: false, accent: false, slide: false, gate: true),
        Abl3PatternStep(pitch: 0, up: false, down: false, accent: false, slide: false, gate: true),
        Abl3PatternStep(pitch: 0, up: false, down: false, accent: false, slide: false, gate: true),
        Abl3PatternStep(pitch: 0, up: false, down: false, accent: false, slide: false, gate: true),
        Abl3PatternStep(pitch: 0, up: false, down: false, accent: false, slide: false, gate: true),
        Abl3PatternStep(pitch: 0, up: false, down: false, accent: false, slide: false, gate: true),
        Abl3PatternStep(pitch: 0, up: false, down: false, accent: false, slide: false, gate: true),
        Abl3PatternStep(pitch: 0, up: false, down: false, accent: false, slide: false, gate: true),
      ],
    );

    final editorPattern = EditorPatternData.fromAbl3Pattern(abl3Pattern);

    expect(editorPattern.notes, [12, 12, 12, 12, 12, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        reason: 'Notes should match');
    expect(editorPattern.octaves, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        reason: 'Octaves should match');
    expect(editorPattern.gates, List.filled(16, true));
    expect(editorPattern.slides, List.filled(16, false));
    expect(editorPattern.accents, List.filled(16, false));
  });
}
