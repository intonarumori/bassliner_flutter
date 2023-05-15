import 'dart:math';
import 'dart:typed_data';

import 'package:bassliner/data/pattern_data.dart';

class Td3PatternData {
  List<int> pitches;
  List<int> accents;
  List<int> slides;
  List<int> separates;
  List<int> rests;
  bool triplets;
  int stepCount;

  Td3PatternData({
    required this.pitches,
    required this.accents,
    required this.separates,
    required this.slides,
    required this.rests,
    required this.triplets,
    required this.stepCount,
  });
}

class PatternParser {
  static const int dataSize = 121;
  static const int maxStepCount = 16;
  static const int notesInOctave = 12;
  static const int defaultPitch = 24;
  static const int maxPitch = 60;

  static Uint8List convertToData(Td3PatternData patternData, int group, int pattern) {
    final data = Uint8List(dataSize);

    // behringer header
    data[0] = 0x00;
    data[1] = 0x20;
    data[2] = 0x32;
    data[3] = 0x00;
    data[4] = 0x01;
    data[5] = 0x0A;

    // command
    data[6] = 0x78;

    // target
    data[7] = group;
    data[8] = pattern;

    // unused
    data[9] = 0x00;
    data[10] = 0x00;

    // rest of data is 118 bytes

    // pitches
    const int pitchesStartIndex = 11;
    for (int i = 0; i < maxStepCount; ++i) {
      final value = patternData.pitches[i];
      data[pitchesStartIndex + i * 2] = (value >> 4) & 0xF;
      data[pitchesStartIndex + i * 2 + 1] = value & 0xF;
    }

    // Accents
    const int accentsStartIndex = 43;
    for (int i = 0; i < maxStepCount; ++i) {
      final value = patternData.accents[i];
      data[accentsStartIndex + i * 2] = (value >> 4) & 0xF;
      data[accentsStartIndex + i * 2 + 1] = value & 0xF;
    }

    // slides
    const int slidesStartIndex = 75;
    for (int i = 0; i < maxStepCount; ++i) {
      final value = patternData.slides[i];
      data[slidesStartIndex + i * 2] = 0;
      data[slidesStartIndex + i * 2 + 1] = value & 0xF;
    }
    data[107] = 0x0;
    data[108] = patternData.triplets ? 1 : 0;
    data[109] = 0x0;
    data[110] = patternData.stepCount;
    data[111] = 0x0;
    data[112] = 0x0;

    data[113] = (patternData.separates[7] << 3) |
        (patternData.separates[6] << 2) |
        (patternData.separates[5] << 1) |
        patternData.separates[4];
    data[114] = (patternData.separates[3] << 3) |
        (patternData.separates[2] << 2) |
        (patternData.separates[1] << 1) |
        patternData.separates[0];
    data[115] = (patternData.separates[15] << 3) |
        (patternData.separates[14] << 2) |
        (patternData.separates[13] << 1) |
        patternData.separates[12];
    data[116] = (patternData.separates[11] << 3) |
        (patternData.separates[10] << 2) |
        (patternData.separates[9] << 1) |
        patternData.separates[8];

    data[117] = (patternData.rests[7] << 3) |
        (patternData.rests[6] << 2) |
        (patternData.rests[5] << 1) |
        patternData.rests[4];
    data[118] = (patternData.rests[3] << 3) |
        (patternData.rests[2] << 2) |
        (patternData.rests[1] << 1) |
        patternData.rests[0];
    data[119] = (patternData.rests[15] << 3) |
        (patternData.rests[14] << 2) |
        (patternData.rests[13] << 1) |
        patternData.rests[12];
    data[120] = (patternData.rests[11] << 3) |
        (patternData.rests[10] << 2) |
        (patternData.rests[9] << 1) |
        patternData.rests[8];

    return data;
  }

  static Td3PatternData? parseData(Uint8List data) {
    if (data.length < 100) return null;

    bool isBehringerTD3 = (data[0] == 0x00 &&
        data[1] == 0x20 &&
        data[2] == 0x32 &&
        data[3] == 0x00 &&
        data[4] == 0x01 &&
        data[5] == 0x0A);

    if (isBehringerTD3 && data[6] == 0x78) {
      // pattern response
      // rest of data is 118 bytes

      List<int> pitches = List.filled(maxStepCount, 0);
      List<int> accents = List.filled(maxStepCount, 0);
      List<int> slides = List.filled(maxStepCount, 0);
      List<int> separates = List.filled(maxStepCount, 0);
      List<int> rests = List.filled(maxStepCount, 0);

      const int pitchesStartIndex = 11;
      for (int i = 0; i < maxStepCount; ++i) {
        final byte1 = data[pitchesStartIndex + i * 2];
        final byte0 = data[pitchesStartIndex + i * 2 + 1];

        final value = (byte1 & 0xF) << 4 | (byte0 & 0xF);
        pitches[i] = value;
      }

      const int accentsStartIndex = 43;
      for (int i = 0; i < maxStepCount; ++i) {
        final byte = data[accentsStartIndex + i * 2 + 1];
        accents[i] = byte;
      }

      const int slidesStartIndex = 75;
      for (int i = 0; i < maxStepCount; ++i) {
        final byte = data[slidesStartIndex + i * 2 + 1];
        slides[i] = byte;
      }

      final triplets = data[108];
      final stepCount = data[110];

      separates[7] = (data[113] >> 3) & 0x1;
      separates[6] = (data[113] >> 2) & 0x1;
      separates[5] = (data[113] >> 1) & 0x1;
      separates[4] = (data[113] >> 0) & 0x1;
      separates[3] = (data[114] >> 3) & 0x1;
      separates[2] = (data[114] >> 2) & 0x1;
      separates[1] = (data[114] >> 1) & 0x1;
      separates[0] = (data[114] >> 0) & 0x1;
      separates[15] = (data[115] >> 3) & 0x1;
      separates[14] = (data[115] >> 2) & 0x1;
      separates[13] = (data[115] >> 1) & 0x1;
      separates[12] = (data[115] >> 0) & 0x1;
      separates[11] = (data[116] >> 3) & 0x1;
      separates[10] = (data[116] >> 2) & 0x1;
      separates[9] = (data[116] >> 1) & 0x1;
      separates[8] = (data[116] >> 0) & 0x1;

      rests[7] = (data[117] >> 3) & 0x1;
      rests[6] = (data[117] >> 2) & 0x1;
      rests[5] = (data[117] >> 1) & 0x1;
      rests[4] = (data[117] >> 0) & 0x1;
      rests[3] = (data[118] >> 3) & 0x1;
      rests[2] = (data[118] >> 2) & 0x1;
      rests[1] = (data[118] >> 1) & 0x1;
      rests[0] = (data[118] >> 0) & 0x1;
      rests[15] = (data[119] >> 3) & 0x1;
      rests[14] = (data[119] >> 2) & 0x1;
      rests[13] = (data[119] >> 1) & 0x1;
      rests[12] = (data[119] >> 0) & 0x1;
      rests[11] = (data[120] >> 3) & 0x1;
      rests[10] = (data[120] >> 2) & 0x1;
      rests[9] = (data[120] >> 1) & 0x1;
      rests[8] = (data[120] >> 0) & 0x1;

      return Td3PatternData(
        pitches: pitches,
        accents: accents,
        separates: separates,
        slides: slides,
        rests: rests,
        triplets: triplets == 1,
        stepCount: stepCount,
      );
    }
    return null;
  }

  static EditorPatternData convertTd3PatternDataToEditorPatternData(Td3PatternData patternData) {
    final stepCount = patternData.stepCount == 0 ? maxStepCount : patternData.stepCount;
    final triplets = patternData.triplets;
    final List<int> pitches = List.filled(maxStepCount, 0);
    final List<bool> accents = List.filled(maxStepCount, false);
    final List<bool> slides = List.filled(maxStepCount, false);
    final List<bool> gates = List.filled(maxStepCount, false);
    final List<int> octaves = List.filled(maxStepCount, 0);

    int currentNoteIndex = 0;

    for (int stepIndex = 0; stepIndex < maxStepCount; ++stepIndex) {
      bool rest = patternData.rests[stepIndex] == 1;
      bool separate = patternData.separates[stepIndex] == 1;

      if (rest || stepIndex >= stepCount) {
        // it's a rest or steps beyond stepcount
        pitches[stepIndex] = 0;
        octaves[stepIndex] = 1;
        accents[stepIndex] = false;
        slides[stepIndex] = false;
        gates[stepIndex] = stepIndex >= stepCount;
      } else {
        // not rest
        final nextIndex = (stepIndex + 1) % stepCount;
        final previousIndex = (stepIndex - 1 + stepCount) % stepCount;

        final nextSeparate =
            patternData.separates[nextIndex] == 1 || patternData.rests[nextIndex] == 1;
        final previousRest = patternData.rests[previousIndex] == 1;

        if (!separate && previousRest) {
          pitches[stepIndex] = 0;
          octaves[stepIndex] = 1;
          accents[stepIndex] = false;
          slides[stepIndex] = false;
          gates[stepIndex] = stepIndex >= stepCount;
        } else {
          int pitch = patternData.pitches[currentNoteIndex];
          // fix the upper notes
          switch (pitch) {
            case 152:
              pitch = 24;
              break;
            case 164:
              pitch = 36;
              break;
            case 176:
              pitch = 48;
              break;
            default:
              break;
          }
          pitch = min(pitch, maxPitch);

          final accent = patternData.accents[currentNoteIndex] == 1;
          final slide = patternData.slides[currentNoteIndex] == 1;
          final tied = !nextSeparate;

          int localPitch = pitch % notesInOctave;
          int octave = (pitch / notesInOctave).floor() - 1;
          while (octave > 2) {
            octave -= 1;
            localPitch = 12;
          }

          pitches[stepIndex] = localPitch;
          octaves[stepIndex] = octave;
          accents[stepIndex] = accent;
          slides[stepIndex] = slide || tied;
          gates[stepIndex] = true;

          if (nextSeparate) {
            currentNoteIndex += 1;
          }
        }
      }
    }
    return EditorPatternData(
      notes: pitches,
      accents: accents,
      slides: slides,
      gates: gates,
      octaves: octaves,
      triplets: triplets,
      steps: stepCount,
    );
  }

  static Td3PatternData convertEditorPatternDataToTd3PatternData(EditorPatternData parameters) {
    final stepCount = parameters.steps;
    final triplets = parameters.triplets;
    final List<int> pitches = List.filled(maxStepCount, defaultPitch);
    final List<int> accents = List.filled(maxStepCount, 0);
    final List<int> slides = List.filled(maxStepCount, 0);
    final List<int> separates = List.filled(maxStepCount, 0);
    final List<int> rests = List.filled(maxStepCount, 0);

    // write steps
    for (int stepIndex = 0; stepIndex < maxStepCount; ++stepIndex) {
      final step = parameters.gates[stepIndex];
      final rest = (stepIndex < stepCount) ? !step : true;
      rests[stepIndex] = rest ? 1 : 0;
    }

    int noteWriteIndex = -1;

    for (int index = 0; index < stepCount; ++index) {
      final currentStep = parameters.gates[index];
      if (currentStep) {
        // current, previous data
        final currentPitch =
            parameters.notes[index] + (parameters.octaves[index] + 1) * notesInOctave;
        final currentSlide = parameters.slides[index];
        final currentAccent = parameters.accents[index];

        final previousIndex = (index - 1 + stepCount) % stepCount;
        final previosStep = parameters.gates[previousIndex];
        final previousPitch = parameters.notes[previousIndex] +
            (parameters.octaves[previousIndex] + 1) * notesInOctave;
        final previousSlide = parameters.slides[previousIndex];
        final previousAccent = parameters.accents[previousIndex];

        bool noteEndSlide = currentSlide;

        if (currentSlide) {
          for (int lastStepInNoteIndex = index + 1;
              lastStepInNoteIndex < stepCount;
              ++lastStepInNoteIndex) {
            final lastStep = parameters.gates[lastStepInNoteIndex];
            final lastPitch = parameters.notes[lastStepInNoteIndex] +
                (parameters.octaves[lastStepInNoteIndex] + 1) * notesInOctave;
            final lastSlide = parameters.slides[lastStepInNoteIndex];
            final lastAccent = parameters.accents[lastStepInNoteIndex];

            if (!lastStep || (lastPitch != currentPitch || lastAccent != currentAccent)) {
              break;
            }
            noteEndSlide = lastSlide;
          }
        }

        // Find out separate

        bool separate = true;

        if (index == 0) {
          separate = true;
        } else {
          if (previosStep && previousSlide) {
            final sameAccent = (previousAccent == currentAccent);
            final samePitch = (previousPitch == currentPitch);
            separate = !(sameAccent && samePitch);
          } else {
            separate = true;
          }
        }

        //

        if (separate) {
          noteWriteIndex += 1;

          if (currentSlide) slides[noteWriteIndex] = noteEndSlide ? 1 : 0;

          pitches[noteWriteIndex] = currentPitch;

          final resultAccent = (currentAccent && separate);

          accents[noteWriteIndex] = resultAccent ? 1 : 0; // only accent when it's a separate note
        } else {
          // if it's not separate we don't write anything
        }

        separates[index] = separate ? 1 : 0;
      } else {
        // it's a rest
        separates[index] = 0;
      }
    }

    return Td3PatternData(
      pitches: pitches,
      accents: accents,
      separates: separates,
      slides: slides,
      rests: rests,
      triplets: triplets,
      stepCount: parameters.steps == maxStepCount ? 0 : parameters.steps,
    );
  }
}
