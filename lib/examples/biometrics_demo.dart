import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/auth/biometric_providers.dart';
import 'package:flutter_riverpod_clean_architecture/core/auth/biometric_service.dart';
import 'package:flutter_riverpod_clean_architecture/core/analytics/analytics_providers.dart';

/// A widget that demonstrates the biometric authentication capabilities
class BiometricsDemo extends ConsumerWidget {
  const BiometricsDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final biometricService = ref.watch(biometricServiceProvider);
    final analytics = ref.watch(analyticsProvider);
    final biometricController = ref.watch(biometricAuthControllerProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Biometric Authentication',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Spacer(),
                Icon(Icons.fingerprint, color: Theme.of(context).primaryColor),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            FutureBuilder<bool>(
              future: biometricService.isAvailable(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final isAvailable = snapshot.data ?? false;

                if (!isAvailable) {
                  return const Card(
                    color: Color(0xFFFFF3E0),
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Biometrics not available on this device'),
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Authentication Status: ${biometricController.isAuthenticated ? "Authenticated" : "Not Authenticated"}',
                      style: TextStyle(
                        color:
                            biometricController.isAuthenticated
                                ? Colors.green
                                : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (biometricController.lastAuthTime != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          'Last authenticated: ${biometricController.lastAuthTime!.toLocal()}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    const SizedBox(height: 16),
                    FutureBuilder<List<BiometricType>>(
                      future: biometricService.getAvailableBiometrics(),
                      builder: (context, snapshot) {
                        final biometrics = snapshot.data ?? [];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Available methods:'),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: [
                                if (biometrics.contains(
                                  BiometricType.fingerprint,
                                ))
                                  Chip(
                                    avatar: const Icon(
                                      Icons.fingerprint,
                                      size: 16,
                                    ),
                                    label: const Text('Fingerprint'),
                                  ),
                                if (biometrics.contains(BiometricType.face))
                                  Chip(
                                    avatar: const Icon(Icons.face, size: 16),
                                    label: const Text('Face ID'),
                                  ),
                                if (biometrics.contains(BiometricType.iris))
                                  Chip(
                                    avatar: const Icon(
                                      Icons.remove_red_eye,
                                      size: 16,
                                    ),
                                    label: const Text('Iris'),
                                  ),
                                if (biometrics.isEmpty)
                                  const Chip(
                                    avatar: Icon(Icons.error_outline, size: 16),
                                    label: Text('None'),
                                  ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.lock_open),
                            label: const Text('App Access'),
                            onPressed: () async {
                              analytics.logUserAction(
                                action: 'biometric_authentication_attempted',
                                category: 'security',
                              );

                              final result = await biometricController
                                  .authenticate(
                                    reason:
                                        'Authenticate to access secure features',
                                    authReason: AuthReason.appAccess,
                                  );

                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Authentication result: $result',
                                    ),
                                    backgroundColor:
                                        result == BiometricResult.success
                                            ? Colors.green
                                            : Colors.red,
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.payments),
                            label: const Text('Transaction'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepOrange,
                            ),
                            onPressed: () async {
                              analytics.logUserAction(
                                action: 'biometric_transaction_attempted',
                                category: 'payment',
                              );

                              final result = await biometricController
                                  .authenticate(
                                    reason:
                                        'Authenticate to complete your payment',
                                    authReason: AuthReason.transaction,
                                    sensitiveTransaction: true,
                                  );

                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Transaction result: $result',
                                    ),
                                    backgroundColor:
                                        result == BiometricResult.success
                                            ? Colors.green
                                            : Colors.red,
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    if (biometricController.isAuthenticated)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: TextButton.icon(
                          icon: const Icon(Icons.logout),
                          label: const Text('Log Out'),
                          onPressed: () {
                            biometricController.logout();
                          },
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
