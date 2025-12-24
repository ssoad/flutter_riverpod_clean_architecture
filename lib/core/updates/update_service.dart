import 'dart:io';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// Result of an app version check
enum UpdateCheckResult {
  /// The app is up to date
  upToDate,

  /// An optional update is available
  updateAvailable,

  /// A critical update is required
  criticalUpdateRequired,

  /// The check failed or couldn't be performed
  checkFailed,
}

/// Information about an available update
class UpdateInfo {
  /// The latest version available
  final String latestVersion;

  /// The minimum required version
  final String minimumRequiredVersion;

  /// Whether the update is critical
  final bool isCritical;

  /// Release notes for the latest version
  final String? releaseNotes;

  /// URL to update the app (store URL)
  final String? updateUrl;

  /// Create update info
  const UpdateInfo({
    required this.latestVersion,
    required this.minimumRequiredVersion,
    required this.isCritical,
    this.releaseNotes,
    this.updateUrl,
  });

  /// Create a copy of this update info with the given fields replaced
  UpdateInfo copyWith({
    String? latestVersion,
    String? minimumRequiredVersion,
    bool? isCritical,
    String? releaseNotes,
    String? updateUrl,
  }) {
    return UpdateInfo(
      latestVersion: latestVersion ?? this.latestVersion,
      minimumRequiredVersion:
          minimumRequiredVersion ?? this.minimumRequiredVersion,
      isCritical: isCritical ?? this.isCritical,
      releaseNotes: releaseNotes ?? this.releaseNotes,
      updateUrl: updateUrl ?? this.updateUrl,
    );
  }
}

/// Interface for app update services
abstract class UpdateService {
  /// Check if an update is available
  Future<UpdateCheckResult> checkForUpdates();

  /// Get information about the available update
  Future<UpdateInfo?> getUpdateInfo();

  /// Prompt the user to update the app
  Future<bool> promptUpdate({bool force = false});

  /// Open the app store to update the app
  Future<bool> openUpdateUrl();

  /// Initialize the update service
  Future<void> init();

  /// Compare version strings to determine if an update is needed
  bool isUpdateNeeded(String currentVersion, String latestVersion);

  /// Determine if an update is critical
  bool isCriticalUpdate(String currentVersion, String minimumRequired);
}

/// A basic implementation of the update service
class BasicUpdateService implements UpdateService {
  final String _androidPackageName;
  final String _iOSAppId;

  PackageInfo? _packageInfo;
  UpdateInfo? _updateInfo;

  /// Create a basic update service
  BasicUpdateService({
    required String androidPackageName,
    required String iOSAppId,
  }) : _androidPackageName = androidPackageName,
       _iOSAppId = iOSAppId;

  @override
  Future<void> init() async {
    // Get the package info
    _packageInfo = await PackageInfo.fromPlatform();
    debugPrint(
      '⬆️ Update service initialized: v${_packageInfo?.version}+${_packageInfo?.buildNumber}',
    );
  }

  @override
  Future<UpdateCheckResult> checkForUpdates() async {
    try {
      // Make sure we're initialized
      if (_packageInfo == null) {
        await init();
      }

      // In a real implementation, this would make a network request to check for updates
      // For this example, we'll just simulate it with some sample data
      await Future.delayed(const Duration(seconds: 1));

      // Simulate fetching update info from a server
      _updateInfo = await _fetchUpdateInfo();

      // Check if update is needed
      if (_updateInfo == null) {
        return UpdateCheckResult.checkFailed;
      }

      // Check if this is a critical update
      if (isCriticalUpdate(
        _packageInfo!.version,
        _updateInfo!.minimumRequiredVersion,
      )) {
        return UpdateCheckResult.criticalUpdateRequired;
      }

      // Check if an update is available
      if (isUpdateNeeded(_packageInfo!.version, _updateInfo!.latestVersion)) {
        return UpdateCheckResult.updateAvailable;
      }

      return UpdateCheckResult.upToDate;
    } catch (e) {
      debugPrint('⬆️ Update check failed: $e');
      return UpdateCheckResult.checkFailed;
    }
  }

  @override
  Future<UpdateInfo?> getUpdateInfo() async {
    if (_updateInfo == null) {
      await checkForUpdates();
    }
    return _updateInfo;
  }

  @override
  Future<bool> promptUpdate({bool force = false}) async {
    // Make sure we have update info
    final updateInfo = await getUpdateInfo();
    if (updateInfo == null) {
      return false;
    }

    debugPrint(
      '⬆️ Prompting for update to version ${updateInfo.latestVersion} '
      '(current: ${_packageInfo?.version})',
    );

    // In a real app, this would show a dialog to the user
    // Return true if the user agrees to update
    return true;
  }

  @override
  Future<bool> openUpdateUrl() async {
    try {
      final updateInfo = await getUpdateInfo();
      if (updateInfo?.updateUrl != null) {
        // Launch the update URL if available
        return await _launchUrl(updateInfo!.updateUrl!);
      }

      // Fall back to store URL based on platform
      String url;
      if (Platform.isAndroid) {
        url =
            'https://play.google.com/store/apps/details?id=$_androidPackageName';
      } else if (Platform.isIOS) {
        url = 'https://apps.apple.com/app/id$_iOSAppId';
      } else {
        return false;
      }

      return await _launchUrl(url);
    } catch (e) {
      debugPrint('⬆️ Failed to open update URL: $e');
      return false;
    }
  }

  @override
  bool isUpdateNeeded(String currentVersion, String latestVersion) {
    // Compare semantic versions
    // This is a simplified version that only compares major.minor.patch
    try {
      final current = _parseVersion(currentVersion);
      final latest = _parseVersion(latestVersion);

      // Compare major version
      if (latest[0] > current[0]) return true;
      if (latest[0] < current[0]) return false;

      // Compare minor version
      if (latest[1] > current[1]) return true;
      if (latest[1] < current[1]) return false;

      // Compare patch version
      return latest[2] > current[2];
    } catch (e) {
      debugPrint('⬆️ Version comparison error: $e');
      return false;
    }
  }

  @override
  bool isCriticalUpdate(String currentVersion, String minimumRequired) {
    try {
      final current = _parseVersion(currentVersion);
      final minimum = _parseVersion(minimumRequired);

      // If the current version is below the minimum required, it's a critical update
      if (current[0] < minimum[0]) return true;
      if (current[0] > minimum[0]) return false;

      if (current[1] < minimum[1]) return true;
      if (current[1] > minimum[1]) return false;

      return current[2] < minimum[2];
    } catch (e) {
      debugPrint('⬆️ Critical update check error: $e');
      return false;
    }
  }

  // Helper to parse a version string like "1.2.3" into a list of integers [1, 2, 3]
  List<int> _parseVersion(String version) {
    final parts = version.split('.');

    if (parts.length < 3) {
      // Pad with zeros if fewer than 3 parts
      parts.addAll(List.filled(3 - parts.length, '0'));
    }

    return parts.take(3).map((part) {
      // Remove any non-numeric suffixes
      final match = RegExp(r'^\d+').firstMatch(part);
      final digitPart = match != null ? match.group(0) : '0';
      return int.tryParse(digitPart ?? '0') ?? 0;
    }).toList();
  }

  // Helper to launch a URL
  Future<bool> _launchUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      return await launchUrl(Uri.parse(url));
    }
    return false;
  }

  // Simulate fetching update info from a server
  Future<UpdateInfo> _fetchUpdateInfo() async {
    // In a real implementation, this would be fetched from an API or appcast
    // This is just a sample based on the current version of the app
    final currentVersion = _packageInfo?.version ?? '1.0.0';

    // For demo purposes, always return an update one version higher
    final current = _parseVersion(currentVersion);
    final nextVersion = '${current[0]}.${current[1]}.${current[2] + 1}';
    final minRequired = '${current[0]}.${current[1]}.0';

    return UpdateInfo(
      latestVersion: nextVersion,
      minimumRequiredVersion: minRequired,
      isCritical: false,
      releaseNotes: 'Bug fixes and performance improvements.',
      updateUrl: Platform.isAndroid
          ? 'https://play.google.com/store/apps/details?id=$_androidPackageName'
          : 'https://apps.apple.com/app/id$_iOSAppId',
    );
  }
}
