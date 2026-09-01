import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'file_transfer_service.g.dart';

/// Multipart upload and download-with-progress, built directly on Dio.
///
/// Both operations report progress as a 0.0-1.0 fraction via [onProgress];
/// Dio computes it from the `Content-Length`/response size when the server
/// provides one (some servers omit it, in which case progress simply won't
/// reach 1.0 until completion - handle that in the UI rather than assuming
/// it always ticks smoothly).
class FileTransferService {
  FileTransferService(this._dio);

  final Dio _dio;

  /// Uploads [filePath] as `multipart/form-data` to [url], under form field
  /// [fieldName], alongside any extra [fields].
  Future<Response<dynamic>> upload({
    required String url,
    required String filePath,
    String fieldName = 'file',
    Map<String, dynamic>? fields,
    void Function(double progress)? onProgress,
    CancelToken? cancelToken,
  }) async {
    final formData = FormData.fromMap({
      ...?fields,
      fieldName: await MultipartFile.fromFile(filePath),
    });

    return _dio.post<dynamic>(
      url,
      data: formData,
      cancelToken: cancelToken,
      onSendProgress: (sent, total) {
        if (total > 0) onProgress?.call(sent / total);
      },
    );
  }

  /// Downloads [url] to [savePath], reporting progress as bytes arrive.
  Future<Response<dynamic>> download({
    required String url,
    required String savePath,
    void Function(double progress)? onProgress,
    CancelToken? cancelToken,
  }) {
    return _dio.download(
      url,
      savePath,
      cancelToken: cancelToken,
      onReceiveProgress: (received, total) {
        if (total > 0) onProgress?.call(received / total);
      },
    );
  }
}

@riverpod
FileTransferService fileTransferService(Ref ref) => FileTransferService(Dio());
