import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/router.dart';
import 'core/theme/theme_builder.dart';
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

    return MaterialApp.router(
      title: 'GymKit',
      debugShowCheckedModeBanner: false,
      theme: buildGymKitTheme(
        seedColor: Colors.blue,
        cornerRadius: 12.0,
        brightness: Brightness.light,
        font: '',
        inputStyle: 'outlined',
      ),
      darkTheme: buildGymKitTheme(
        seedColor: Colors.blue,
        cornerRadius: 12.0,
        brightness: Brightness.dark,
        font: '',
        inputStyle: 'outlined',
      ),
      routerConfig: router,
    );
  }
}
