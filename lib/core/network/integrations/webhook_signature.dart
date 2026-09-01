import 'dart:convert';

import 'package:crypto/crypto.dart';

/// HMAC-SHA256 request signing, the de-facto standard webhook providers
/// (Stripe, GitHub, Shopify, ...) use to let a receiver prove a payload
/// really came from the sender and was not tampered with in transit.
abstract class WebhookSignature {
  /// Signs [payload] (the exact raw request body, as bytes matter) with
  /// [secret], producing a hex-encoded digest suitable for a header such as
  /// `X-Webhook-Signature: sha256=<digest>`.
  static String sign({required String secret, required String payload}) {
    final hmac = Hmac(sha256, utf8.encode(secret));
    return hmac.convert(utf8.encode(payload)).toString();
  }

  /// Recomputes the signature for [payload] with [secret] and compares it to
  /// [signature] (accepts either the bare hex digest or a `sha256=...`
  /// prefixed value, matching common provider conventions).
  ///
  /// Uses a constant-time comparison so verification time doesn't leak how
  /// many leading bytes of the signature were correct to an attacker.
  static bool verify({
    required String secret,
    required String payload,
    required String signature,
  }) {
    final expected = sign(secret: secret, payload: payload);
    final provided = signature.startsWith('sha256=')
        ? signature.substring('sha256='.length)
        : signature;
    return _constantTimeEquals(expected, provided);
  }

  static bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var result = 0;
    for (var i = 0; i < a.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return result == 0;
  }
}
