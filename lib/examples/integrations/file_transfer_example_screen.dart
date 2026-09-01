import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/integrations/demo_file_ops.dart';
import '../../core/network/integrations/file_transfer_service.dart';

/// Demonstrates multipart file upload and download-with-progress through
/// the reusable [FileTransferService], against two well-known public test
/// endpoints (no auth required):
/// - Upload: `httpbin.org/post`, which echoes back what it received.
/// - Download: `picsum.photos`, a random-image service (also used
///   elsewhere in this template's showcase screens).
///
/// Copy `core/network/integrations/file_transfer_service.dart` into a real
/// feature (avatar upload, document download, media sync, ...) and point it
/// at your own backend.
///
/// Non-web only: saving to a temp file needs a real filesystem, which a
/// browser doesn't expose the way other platforms do.
class FileTransferExampleScreen extends ConsumerStatefulWidget {
  const FileTransferExampleScreen({super.key});

  @override
  ConsumerState<FileTransferExampleScreen> createState() =>
      _FileTransferExampleScreenState();
}

class _FileTransferExampleScreenState
    extends ConsumerState<FileTransferExampleScreen> {
  double? _uploadProgress;
  String? _uploadResult;
  Object? _uploadError;

  double? _downloadProgress;
  String? _downloadedPath;
  Object? _downloadError;

  Future<void> _runUpload() async {
    setState(() {
      _uploadProgress = 0;
      _uploadResult = null;
      _uploadError = null;
    });
    try {
      final path = await writeUploadDemoFile();

      final response = await ref
          .read(fileTransferServiceProvider)
          .upload(
            url: 'https://httpbin.org/post',
            filePath: path,
            fields: {'source': 'flutter_riverpod_clean_architecture'},
            onProgress: (progress) {
              if (mounted) setState(() => _uploadProgress = progress);
            },
          );

      final body = response.data;
      final filesEchoed = body is Map ? body['files'] : null;
      setState(
        () => _uploadResult = filesEchoed != null
            ? 'Server received the file (${demoFileSizeBytes(path)} bytes).'
            : 'Uploaded (unexpected response shape).',
      );
    } catch (e) {
      setState(() => _uploadError = e);
    } finally {
      if (mounted) setState(() => _uploadProgress = null);
    }
  }

  Future<void> _runDownload() async {
    setState(() {
      _downloadProgress = 0;
      _downloadedPath = null;
      _downloadError = null;
    });
    try {
      final savePath = await demoTempPath('template_download_demo.jpg');

      await ref
          .read(fileTransferServiceProvider)
          .download(
            url: 'https://picsum.photos/1200/1200',
            savePath: savePath,
            onProgress: (progress) {
              if (mounted) setState(() => _downloadProgress = progress);
            },
          );

      setState(() => _downloadedPath = savePath);
    } on DioException catch (e) {
      setState(() => _downloadError = e.message ?? e.toString());
    } catch (e) {
      setState(() => _downloadError = e);
    } finally {
      if (mounted) setState(() => _downloadProgress = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('File upload / download')),
      body: kIsWeb
          ? const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'This demo saves files to a temp directory, which is not '
                'available on web. Run it on desktop or mobile.',
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('Upload', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: _uploadProgress == null ? _runUpload : null,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Upload a generated demo file'),
                ),
                if (_uploadProgress != null) ...[
                  const SizedBox(height: 12),
                  LinearProgressIndicator(value: _uploadProgress),
                  Text('${((_uploadProgress ?? 0) * 100).toStringAsFixed(0)}%'),
                ],
                if (_uploadError != null)
                  Text(
                    'Upload failed: $_uploadError',
                    style: const TextStyle(color: Colors.red),
                  ),
                if (_uploadResult != null) Text(_uploadResult!),
                const Divider(height: 32),
                Text(
                  'Download',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: _downloadProgress == null ? _runDownload : null,
                  icon: const Icon(Icons.download),
                  label: const Text('Download a demo image'),
                ),
                if (_downloadProgress != null) ...[
                  const SizedBox(height: 12),
                  LinearProgressIndicator(value: _downloadProgress),
                  Text(
                    '${((_downloadProgress ?? 0) * 100).toStringAsFixed(0)}%',
                  ),
                ],
                if (_downloadError != null)
                  Text(
                    'Download failed: $_downloadError',
                    style: const TextStyle(color: Colors.red),
                  ),
                if (_downloadedPath != null) ...[
                  const SizedBox(height: 12),
                  buildDownloadedImage(_downloadedPath!),
                ],
              ],
            ),
    );
  }
}
