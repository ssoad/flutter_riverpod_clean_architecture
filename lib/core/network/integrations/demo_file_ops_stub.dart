import 'package:flutter/material.dart';

/// Web fallback: there is no filesystem to write a temp file to, and Dio's
/// `download()` cannot save arbitrary bytes to disk in a browser the way it
/// can on other platforms (a browser can only trigger a user-facing save
/// dialog). This demo is offered on non-web platforms only.
Future<String> writeUploadDemoFile() {
  throw UnsupportedError(
    'This demo writes a temp file to disk and is not available on web.',
  );
}

int demoFileSizeBytes(String path) => 0;

Future<String> demoTempPath(String filename) {
  throw UnsupportedError('There is no temp directory to save into on web.');
}

Widget buildDownloadedImage(String path, {double height = 200}) =>
    const SizedBox.shrink();
