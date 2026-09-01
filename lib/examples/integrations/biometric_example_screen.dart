import 'package:flutter/material.dart';

import '../biometrics_demo.dart';

/// A thin, routable wrapper around [BiometricsDemo] - the biometric
/// authentication showcase was fully implemented but had no screen/route of
/// its own, so it was unreachable from the app. This gives it one.
class BiometricExampleScreen extends StatelessWidget {
  const BiometricExampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Biometric authentication')),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: BiometricsDemo(),
      ),
    );
  }
}
