import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod_clean_architecture/core/network/integrations/webhook_signature.dart';

void main() {
  const secret = 'shared-secret';
  const payload = '{"event":"order.shipped","orderId":"1234"}';

  group('WebhookSignature', () {
    test('verify accepts a signature produced by sign', () {
      final signature = WebhookSignature.sign(secret: secret, payload: payload);

      expect(
        WebhookSignature.verify(
          secret: secret,
          payload: payload,
          signature: signature,
        ),
        isTrue,
      );
    });

    test('verify accepts a sha256=-prefixed signature', () {
      final signature = WebhookSignature.sign(secret: secret, payload: payload);

      expect(
        WebhookSignature.verify(
          secret: secret,
          payload: payload,
          signature: 'sha256=$signature',
        ),
        isTrue,
      );
    });

    test('verify rejects a signature from a different secret', () {
      final signature = WebhookSignature.sign(
        secret: 'wrong-secret',
        payload: payload,
      );

      expect(
        WebhookSignature.verify(
          secret: secret,
          payload: payload,
          signature: signature,
        ),
        isFalse,
      );
    });

    test('verify rejects a tampered payload', () {
      final signature = WebhookSignature.sign(secret: secret, payload: payload);

      expect(
        WebhookSignature.verify(
          secret: secret,
          payload: '$payload tampered',
          signature: signature,
        ),
        isFalse,
      );
    });

    test('sign is deterministic for the same inputs', () {
      final first = WebhookSignature.sign(secret: secret, payload: payload);
      final second = WebhookSignature.sign(secret: secret, payload: payload);

      expect(first, equals(second));
    });
  });
}
