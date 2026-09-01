import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../error/failures.dart';
import '../../utils/logger.dart' as core_logger;
import 'webhook_signature.dart';

part 'webhook_sender.g.dart';

/// The result of successfully delivering an outbound webhook.
class WebhookDeliveryResult {
  const WebhookDeliveryResult({
    required this.statusCode,
    required this.body,
    required this.signature,
  });

  final int statusCode;
  final dynamic body;

  /// The `sha256=<digest>` signature that was sent, so the UI/logs can show
  /// exactly what a receiver should verify.
  final String signature;
}

/// Sends an outbound webhook: a plain HTTP POST whose body is signed with
/// HMAC-SHA256 so the receiving endpoint can verify authenticity, following
/// the same convention used by Stripe/GitHub/Shopify.
///
/// This is the "you have events, someone else's server wants to know about
/// them" half of the pattern; [WebhookSignature] holds the shared signing
/// logic and `local_webhook_receiver.dart` shows the receiving half for
/// local development/testing.
class WebhookSender {
  WebhookSender(this._dio);

  final Dio _dio;

  Future<Either<Failure, WebhookDeliveryResult>> send({
    required String url,
    required Map<String, dynamic> payload,
    required String secret,
    Map<String, String>? extraHeaders,
  }) async {
    final body = jsonEncode(payload);
    final signature =
        'sha256=${WebhookSignature.sign(secret: secret, payload: body)}';

    try {
      final response = await _dio.post<dynamic>(
        url,
        data: body,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'X-Webhook-Signature': signature,
            'X-Webhook-Timestamp': DateTime.now().toUtc().toIso8601String(),
            ...?extraHeaders,
          },
        ),
      );
      core_logger.Logger.info(
        'Webhook delivered to $url (status ${response.statusCode})',
      );
      return Right(
        WebhookDeliveryResult(
          statusCode: response.statusCode ?? 0,
          body: response.data,
          signature: signature,
        ),
      );
    } on DioException catch (e) {
      core_logger.Logger.error('Webhook delivery failed', e);
      return Left(
        ServerFailure(
          message: e.response != null
              ? 'Receiver returned ${e.response?.statusCode}'
              : (e.message ?? 'Webhook delivery failed'),
        ),
      );
    }
  }
}

@riverpod
WebhookSender webhookSender(Ref ref) => WebhookSender(Dio());
