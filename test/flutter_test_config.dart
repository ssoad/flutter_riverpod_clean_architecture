import 'dart:async';
import 'dart:typed_data'; // Required for Uint8List
import 'package:flutter/foundation.dart'; // Required for FlutterError
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  await loadAppFonts();

  // Custom comparator with 1.5% tolerance for cross-platform consistency
  // (Handling minor font rendering differences between macOS and Linux CI)
  if (goldenFileComparator is LocalFileComparator) {
    final testUrl = (goldenFileComparator as LocalFileComparator).basedir;
    goldenFileComparator = LocalFileComparatorWithThreshold(
      Uri.parse('$testUrl/test.dart'),
      0.015, // 1.5% tolerance
    );
  }

  return testMain();
}

/// A custom golden file comparator that allows for a small difference in pixels
class LocalFileComparatorWithThreshold extends LocalFileComparator {
  final double threshold;

  LocalFileComparatorWithThreshold(super.testFile, this.threshold);

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final result = await GoldenFileComparator.compareLists(
      imageBytes,
      await getGoldenBytes(golden),
    );

    if (!result.passed && result.diffPercent <= threshold) {
      print(
        'Golden difference of ${result.diffPercent * 100}% '
        'is within threshold of ${threshold * 100}%. Passing.',
      );
      return true;
    }

    if (!result.passed) {
      final error = await generateFailureOutput(result, golden, basedir);
      throw FlutterError(error);
    }
    return true;
  }
}
