import 'dart:async';
import 'dart:typed_data';

import 'package:bassliner/data/pattern_parser.dart';
import 'package:flutter/material.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';
import 'package:rxdart/subjects.dart';

class _Td3SendRequest {
  Td3PatternData patternData;
  int group;
  int pattern;

  _Td3SendRequest(this.patternData, this.group, this.pattern);
}

class Td3Connection {
  static const int sendInterval = 200;

  final _midi = MidiCommand();

  MidiDevice? _td3;

  _Td3SendRequest? _lastRequest;
  late Timer _timer;

  final _patternStream = StreamController<Td3PatternData>();
  Stream<Td3PatternData> get patternStream => _patternStream.stream;

  final connected = BehaviorSubject<bool>.seeded(false);

  StreamSubscription<MidiPacket>? midiDataSubscription;

  // MARK: -

  Td3Connection() {
    _midi.onMidiSetupChanged?.listen((event) {
      _refreshMidi();
    });
    _refreshMidi();

    _timer = Timer.periodic(const Duration(milliseconds: sendInterval), (_) => _sendIfNeeded());
  }

  void _refreshMidi() async {
    final devices = await _midi.devices ?? [];

    midiDataSubscription = _midi.onMidiDataReceived?.listen((event) {
      _handleMidiData(event);
    });

    final td3 =
        devices.firstWhereOrNull((element) => element.name == 'TD-3' || element.name == 'TD-3-MO');

    if (td3 != null) {
      _td3 = td3;
      if (!td3.connected) {
        await _midi.connectToDevice(td3);
      }
      debugPrint('TD-3 found');
      connected.add(true);
    } else {
      connected.add(false);
      debugPrint('TD-3 not found');
    }
  }

  void requestPattern(int group, int pattern) {
    final td3 = _td3;

    if (td3 == null || !td3.connected) {
      debugPrint('TD-3 is not connected');
      return;
    }

    final intData = [0xF0, 0x00, 0x20, 0x32, 0x00, 0x01, 0x0A, 0x77, group, pattern, 0xF7];
    final data = Uint8List.fromList(intData);

    debugPrint('requested pattern $group $pattern');

    _midi.sendData(data, deviceId: td3.id);
  }

  void _handleMidiData(MidiPacket packet) {
    // if (packet.device != _td3) {
    //   debugPrint('Data is not coming from TD-3, discarding');
    //   return;
    // }
    final packetData = packet.data;

    if (packetData.first != 0xF0 || packetData.last != 0xF7) {
      //debugPrint('Discarding non sysex message: $packetData');
      return;
    }

    final data = packet.data.sublist(1, packet.data.length - 1);
    final td3PatternData = PatternParser.parseData(data);

    if (td3PatternData == null) {
      //debugPrint('Could not parse message as TD-3 pattern');
      return;
    }
    _patternStream.add(td3PatternData);
  }

  void sendPatternData(Td3PatternData patternData, int group, int pattern) {
    _lastRequest = _Td3SendRequest(patternData, group, pattern);
    // Timer callback will pick this up
  }

  void _sendIfNeeded() {
    final td3 = _td3;
    if (td3 == null) {
      //debugPrint('TD-3 is not connected');
      return;
    }

    final request = _lastRequest;
    if (request == null) {
      //debugPrint('nothing to send');
      return;
    }
    _lastRequest = null;

    final data = PatternParser.convertToData(request.patternData, request.group, request.pattern);
    final sysexData = Uint8List.fromList([0xF0, ...data, 0xF7]);
    _midi.sendData(sysexData, deviceId: td3.id);

    debugPrint('Pattern sent to TD-3: ${request.group} - ${request.pattern}');
  }
}
