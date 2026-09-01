import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart'; // Required for FlutterError
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

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

/// Loads the application's bundled fonts so that golden tests render real
/// glyphs instead of the placeholder Ahem font.
///
/// This is a small, dependency-free replacement for the equivalent helper that
/// used to be provided by the (now discontinued) `golden_toolkit` package.
Future<void> loadAppFonts() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  final fontManifest = await rootBundle.loadStructuredData<Iterable<dynamic>>(
    'FontManifest.json',
    (data) async => json.decode(data) as Iterable<dynamic>,
  );

  for (final Map<String, dynamic> font in fontManifest) {
    final family = font['family'] as String;
    final fontLoader = FontLoader(_deriveFontFamily(family));
    for (final Map<String, dynamic> fontType in font['fonts']) {
      fontLoader.addFont(rootBundle.load(fontType['asset'] as String));
    }
    await fontLoader.load();
  }
}

/// Flutter ships packaged fonts (e.g. Material Icons) under family names such as
/// `packages/<package>/<family>`. Golden tests expect the bare family name, so
/// strip the package prefix for the well-known bundled families.
String _deriveFontFamily(String fontFamily) {
  if (!fontFamily.startsWith('packages/')) {
    return fontFamily;
  }
  final segments = fontFamily.split('/');
  const overridableFonts = <String>{
    'MaterialIcons',
    'CupertinoIcons',
    'FontAwesome',
  };
  if (overridableFonts.contains(segments.last)) {
    return segments.last;
  }
  return fontFamily;
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
      debugPrint(
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
