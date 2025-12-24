import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/presentation/screens/login_screen.dart';

void main() {
  testGoldens('LoginScreen golden test', (tester) async {
    final builder = DeviceBuilder()
      ..overrideDevicesForAllScenarios(
        devices: [Device.phone, Device.iphone11, Device.tabletPortrait],
      )
      ..addScenario(
        widget: ProviderScope(
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            // Basic theme
            theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
            home: const LoginScreen(),
          ),
        ),
        name: 'default_login_state',
      );

    await tester.pumpDeviceBuilder(builder);

    await screenMatchesGolden(tester, 'login_screen');
  });
}
