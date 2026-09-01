// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'webhook_sender.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(webhookSender)
final webhookSenderProvider = WebhookSenderProvider._();

final class WebhookSenderProvider
    extends $FunctionalProvider<WebhookSender, WebhookSender, WebhookSender>
    with $Provider<WebhookSender> {
  WebhookSenderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'webhookSenderProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$webhookSenderHash();

  @$internal
  @override
  $ProviderElement<WebhookSender> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  WebhookSender create(Ref ref) {
    return webhookSender(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WebhookSender value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WebhookSender>(value),
    );
  }
}

String _$webhookSenderHash() => r'b99530a3624d0f22589190acc203a1a80681c72f';
