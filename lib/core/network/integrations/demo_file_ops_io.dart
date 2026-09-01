import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

/// Writes a generated text file to the temp directory for the upload demo
/// to send, and returns its path.
Future<String> writeUploadDemoFile() async {
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/template_upload_demo.txt');
  await file.writeAsString('Sample upload content. ' * 5000);
  return file.path;
}

int demoFileSizeBytes(String path) => File(path).lengthSync();

/// A path under the temp directory for [filename], for the download demo
/// to save into.
Future<String> demoTempPath(String filename) async {
  final dir = await getTemporaryDirectory();
  return '${dir.path}/$filename';
}

/// Renders a file the download demo just saved.
Widget buildDownloadedImage(String path, {double height = 200}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(8),
    child: Image.file(File(path), height: height),
  );
}
