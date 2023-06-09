import 'package:flutter/foundation.dart';

class Abl3Pattern {
  final Abl3SynthParameters parameters;
  final List<Abl3PatternStep> steps;

  const Abl3Pattern({required this.parameters, required this.steps});

  @override
  String toString() {
    String str = '[ABL3Pattern]\n';
    for (final step in steps) {
      str += '  Step: ${step.toString()}\n';
    }
    return str;
  }

  @override
  bool operator ==(Object other) =>
      other is Abl3Pattern &&
      other.runtimeType == runtimeType &&
      other.parameters == parameters &&
      listEquals(other.steps, steps);

  @override
  int get hashCode => parameters.hashCode ^ steps.hashCode;
}

class Abl3SynthParameters {
  final double triplet;
  final double shuffle;

  const Abl3SynthParameters({
    required this.triplet,
    required this.shuffle,
  });

  @override
  bool operator ==(Object other) =>
      other is Abl3SynthParameters &&
      other.runtimeType == runtimeType &&
      other.triplet == triplet &&
      other.shuffle == shuffle;

  @override
  int get hashCode => triplet.hashCode ^ shuffle.hashCode;
}

class Abl3PatternStep {
  final int pitch;
  final bool up;
  final bool down;
  final bool accent;
  final bool slide;
  final bool gate;

  const Abl3PatternStep({
    required this.pitch,
    required this.up,
    required this.down,
    required this.accent,
    required this.slide,
    required this.gate,
  });

  @override
  bool operator ==(Object other) =>
      other is Abl3PatternStep &&
      other.runtimeType == runtimeType &&
      other.pitch == pitch &&
      other.up == up &&
      other.down == down &&
      other.accent == accent &&
      other.slide == slide &&
      other.gate == gate;

  @override
  int get hashCode =>
      pitch.hashCode ^
      up.hashCode ^
      down.hashCode ^
      accent.hashCode ^
      slide.hashCode ^
      gate.hashCode;

  @override
  String toString() {
    return '[Abl3PatternStep] gate:$gate pitch:$pitch up:$up down:$down accent:$accent slide:$slide';
  }
}

// MARK: -

class Abl3ParseException implements Exception {
  String cause;
  Abl3ParseException(this.cause);
}

class Abl3Version9PatternParser {
  // The newer format
// ; ABL3 Meta tag: 9
// ; Triplet: 0.000000 Shuffle: 0.000000
  //        -12 0 0 0 0 1
  //        -11 1 0 0 0 1
  //        -10 0 1 0 0 1
  //        -9 1 1 0 0 1
  //        -8 0 0 0 0 1
  //        -7 0 0 0 0 1
  //        -6 0 0 0 0 1
  //        -5 0 0 0 0 1
  //        -4 0 0 0 0 1
  //        -3 0 0 0 0 1
  //        -2 0 0 0 0 1
  //        -1 0 0 0 0 1
  //        0 0 0 0 0 1
  //        1 0 0 0 0 1
  //        2 0 0 0 0 1
  //        3 0 0 0 0 1
  static const metaHeader = '; ABL3 Meta tag: 9';

  static String serializePattern(Abl3Pattern pattern) {
    String string = '';
    string += '$metaHeader\n';

    Map<String, String> params = {};
    params['Triplet'] = pattern.parameters.triplet.toStringAsFixed(6);
    params['Shuffle'] = pattern.parameters.shuffle.toStringAsFixed(6);

    final paramString = params.entries.map<String>((e) => '${e.key}: ${e.value}').join(' ');
    string += "; $paramString\n";

    for (final step in pattern.steps) {
      final str =
          "${step.pitch} ${step.up ? 1 : 0} ${step.down ? 1 : 0} ${step.accent ? 1 : 0} ${step.slide ? 1 : 0} ${step.gate ? 1 : 0}";
      string += '$str\n';
    }
    return string;
  }

  static Abl3Pattern parsePattern(String string) {
    final lines = string.split('\n');

    if (lines.length < 2 || lines.first.trim() != metaHeader) {
      throw Abl3ParseException('Invalid header');
    }

    // parse lines[1] for synth parameters
    final synthParamParts = lines[1].trim().split(' ');
    if (synthParamParts.length < 2) {
      throw Abl3ParseException('Invalid parameters');
    }

    double triplet = 0;
    double shuffle = 0;

    int index = 0;
    while (true) {
      if (synthParamParts.length < (index * 2 + 2)) {
        break;
      }
      final name = synthParamParts[index * 2 + 1].trim();
      final value = double.parse(synthParamParts[index * 2 + 2].trim());

      switch (name) {
        case "Triplet:":
          triplet = value;
          break;
        case "Shuffle:":
          shuffle = value;
          break;
        default:
          break;
      }
      index += 1;
    }

    final parameters = Abl3SynthParameters(triplet: triplet, shuffle: shuffle);

    final List<Abl3PatternStep> steps = [];

    for (int i = 2; i < lines.length; i++) {
      final line = lines[i];
      if (line.isEmpty) continue;
      final parts = line
          .split(' ')
          .map((e) => int.tryParse(e))
          .where((element) => element != null)
          .map((e) => e!)
          .toList();
      if (parts.length < 6) {
        throw Abl3ParseException('Invalid step content');
      }
      final step = Abl3PatternStep(
          pitch: parts[0],
          up: parts[1] == 1,
          down: parts[2] == 1,
          accent: parts[3] == 1,
          slide: parts[4] == 1,
          gate: parts[5] == 1);
      steps.add(step);
    }

    return Abl3Pattern(parameters: parameters, steps: steps);
  }
}

class Abl3Version16PatternParser {
  // The older format
  //        ; ABL3 Meta tag: 16
  //        ; Tune: 0.500000 Cutoff: 0.324000 Resonance: 0.298000 Envmod: 0.481000 Decay: 0.780000 Accent: 0.674000 Waveform: 0.000000 Volume: 0.550000
  //        -12 0 0 0 0 1
  //        -11 1 0 0 0 1
  //        -10 0 1 0 0 1
  //        -9 1 1 0 0 1
  //        -8 0 0 0 0 1
  //        -7 0 0 0 0 1
  //        -6 0 0 0 0 1
  //        -5 0 0 0 0 1
  //        -4 0 0 0 0 1
  //        -3 0 0 0 0 1
  //        -2 0 0 0 0 1
  //        -1 0 0 0 0 1
  //        0 0 0 0 0 1
  //        1 0 0 0 0 1
  //        2 0 0 0 0 1
  //        3 0 0 0 0 1

  static const metaHeader = '; ABL3 Meta tag: 16';

  static Abl3Pattern parsePattern(String string) {
    final lines = string.split('\n');

    if (lines.length < 2 || lines.first.trim() != metaHeader) {
      throw Abl3ParseException('Invalid header');
    }

    // parse lines[1] for synth parameters
    final synthParamParts = lines[1].trim().split(' ');
    if (synthParamParts.length < 2) {
      throw Abl3ParseException('Invalid parameters');
    }

    double triplet = 0;
    double shuffle = 0;

    int index = 0;
    while (true) {
      if (synthParamParts.length < (index * 2 + 2)) {
        break;
      }
      final name = synthParamParts[index * 2 + 1].trim();
      final value = double.parse(synthParamParts[index * 2 + 2].trim());

      // We are not retaining these
      debugPrint('synth param $name : $value');

      index += 1;
    }

    final parameters = Abl3SynthParameters(triplet: triplet, shuffle: shuffle);

    final List<Abl3PatternStep> steps = [];

    for (int i = 2; i < lines.length; i++) {
      final line = lines[i];
      if (line.isEmpty) continue;
      final parts = line
          .split(' ')
          .map((e) => int.tryParse(e))
          .where((element) => element != null)
          .map((e) => e!)
          .toList();
      if (parts.length < 6) {
        throw Abl3ParseException('Invalid step content');
      }

      // NOTE:
      // We shift the pitch down one octave
      // This might have been an oversight in the original Bassliner iOS implementation, the notes
      // were probably stored one octave up, so here we try to compensate for it.
      // TODO: some tests to verify old saved patterns will be loaded correctly.
      final step = Abl3PatternStep(
          pitch: parts[0] - 12,
          up: parts[1] == 1,
          down: parts[2] == 1,
          accent: parts[3] == 1,
          slide: parts[4] == 1,
          gate: parts[5] == 1);
      steps.add(step);
    }

    return Abl3Pattern(parameters: parameters, steps: steps);
  }
}
