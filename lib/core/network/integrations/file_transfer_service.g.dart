// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_transfer_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(fileTransferService)
final fileTransferServiceProvider = FileTransferServiceProvider._();

final class FileTransferServiceProvider
    extends
        $FunctionalProvider<
          FileTransferService,
          FileTransferService,
          FileTransferService
        >
    with $Provider<FileTransferService> {
  FileTransferServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'fileTransferServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$fileTransferServiceHash();

  @$internal
  @override
  $ProviderElement<FileTransferService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FileTransferService create(Ref ref) {
    return fileTransferService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FileTransferService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FileTransferService>(value),
    );
  }
}

String _$fileTransferServiceHash() =>
    r'17a86735ed9b6cd6caf147fd84ed370be737e613';
