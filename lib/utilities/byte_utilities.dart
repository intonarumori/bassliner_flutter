import 'dart:math';
import 'package:flutter/foundation.dart';

class ByteUtilities {
  static void compare(Uint8List data0, Uint8List data1) {
    if (data0.length != data1.length) {
      debugPrint('[ByteUtilities] lengths do not match: ${data0.length} != ${data1.length}');
      return;
    }
    final length = data0.length;
    const chunkSize = 16;
    final chunks = (length.toDouble() / chunkSize).ceil();

    for (int i = 0; i < chunks; i++) {
      final chunk0 = data0.sublist(i * chunkSize, min((i + 1) * chunkSize, data0.length));
      final chunk1 = data1.sublist(i * chunkSize, min((i + 1) * chunkSize, data1.length));

      if (listEquals(chunk0, chunk1)) {
        debugPrint('-----: ${chunk0.map((e) => e.toRadixString(16).padLeft(2, '0'))}');
      } else {
        List<int> differences = [];
        for (int j = 0; j < chunk0.length; j++) {
          if (chunk0[j] != chunk1[j]) {
            differences.add(i * chunkSize + j);
          }
        }

        debugPrint('  != : $differences');
        debugPrint('data0: ${chunk0.map((e) => e.toRadixString(16).padLeft(2, '0'))}');
        debugPrint('data1: ${chunk1.map((e) => e.toRadixString(16).padLeft(2, '0'))}');
      }
    }
  }
}
