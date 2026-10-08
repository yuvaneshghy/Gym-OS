import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/router.dart';
import 'core/config/tenant_config.dart';
import 'core/config/tenant_config_repository.dart';
import 'core/theme/theme_builder.dart';
import 'core/theme/theme_mode_provider.dart';
import 'data/pocketbase_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const GymKitApp(),
    ),
  );
}

/// Root widget for the GymKit application.
class GymKitApp extends ConsumerWidget {
  const GymKitApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final configAsync = ref.watch(tenantConfigProvider);
    final config = configAsync.value ?? const TenantConfig();
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: config.gymName.isNotEmpty ? config.gymName : 'GymKit',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: buildGymKitTheme(
        seedColor: config.seedColor,
        cornerRadius: config.cornerRadius,
        brightness: Brightness.light,
        font: config.fontFamily,
        inputStyle: config.inputStyle,
      ),
      darkTheme: buildGymKitTheme(
        seedColor: config.seedColor,
        cornerRadius: config.cornerRadius,
        brightness: Brightness.dark,
        font: config.fontFamily,
        inputStyle: config.inputStyle,
      ),
      routerConfig: router,
    );
  }
}
