import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Default PocketBase URL. Override per tenant via --dart-define.
const _kDefaultPbUrl = String.fromEnvironment(
  'PB_URL',
  defaultValue: 'http://127.0.0.1:8090',
);

/// Shared preferences instance — must be initialized before use.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden at app startup.',
  );
});

/// Provides the PocketBase client with persistent auth store.
final pocketBaseProvider = Provider<PocketBase>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);

  final store = AsyncAuthStore(
    save: (String data) async => prefs.setString('pb_auth', data),
    initial: prefs.getString('pb_auth'),
  );

  return PocketBase(_kDefaultPbUrl, authStore: store);
});
