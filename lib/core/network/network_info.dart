// Network Information Interface
// Provides network connectivity information

import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Abstract interface for network connectivity information
abstract class NetworkInfo {
  /// Check if the device is connected to the internet
  Future<bool> get isConnected;
}

/// Implementation of NetworkInfo using basic connectivity check
class NetworkInfoImpl implements NetworkInfo {
  @override
  Future<bool> get isConnected async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }
}

/// Riverpod provider for NetworkInfo
final networkInfoProvider = Provider<NetworkInfo>(
  (ref) => NetworkInfoImpl(),
);