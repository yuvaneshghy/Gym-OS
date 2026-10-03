import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/pocketbase_client.dart';
import 'tenant_config.dart';

/// Repository that manages loading and caching the TenantConfig.
final tenantConfigRepositoryProvider = Provider<TenantConfigRepository>((ref) {
  return TenantConfigRepository(
    ref.watch(pocketBaseProvider),
    ref.watch(sharedPreferencesProvider),
  );
});

/// Exposes the current TenantConfig, fetching from cache then API.
final tenantConfigProvider = FutureProvider<TenantConfig>((ref) async {
  return ref.watch(tenantConfigRepositoryProvider).getConfig();
});

class TenantConfigRepository {
  TenantConfigRepository(this._pb, this._prefs);

  final PocketBase _pb;
  final SharedPreferences _prefs;
  static const _cacheKey = 'tenant_config_cache';

  Future<TenantConfig> getConfig() async {
    // 1. Load from cache first
    final cached = _prefs.getString(_cacheKey);
    TenantConfig? config;
    if (cached != null) {
      try {
        config = TenantConfig.fromJson(jsonDecode(cached) as Map<String, dynamic>);
      } on Object catch (_) {}
    }

    // 2. Fetch from PocketBase in background to update cache
    // ignore: unawaited_futures
    _fetchAndCache();

    // 3. Return cache or default if no cache
    return config ?? const TenantConfig();
  }

  Future<void> updateConfig(TenantConfig newConfig) async {
    final record = await _pb.collection('app_config').getFirstListItem('', query: {'sort': '-updated'});
    await _pb.collection('app_config').update(record.id, body: newConfig.toJson());
    await _fetchAndCache();
  }

  Future<void> uploadLogo(XFile file) async {
    final record = await _pb.collection('app_config').getFirstListItem('', query: {'sort': '-updated'});
    final bytes = await file.readAsBytes();
    final multipartFile = http.MultipartFile.fromBytes(
      'logo',
      bytes,
      filename: file.name,
    );
    await _pb.collection('app_config').update(
      record.id,
      files: [multipartFile],
    );
    await _fetchAndCache();
  }

  Future<void> cacheConfig(TenantConfig newConfig) async {
    await _prefs.setString(_cacheKey, jsonEncode(newConfig.toJson()));
  }

  Future<void> _fetchAndCache() async {
    try {
      final record = await _pb.collection('app_config').getFirstListItem('', query: {'sort': '-updated'});
      final data = record.data;
      final logoFilename = record.getStringValue('logo');
      if (logoFilename.isNotEmpty) {
        data['logo_url'] = _pb.files.getUrl(record, logoFilename).toString();
      } else {
        data['logo_url'] = '';
      }
      await _prefs.setString(_cacheKey, jsonEncode(data));
    } on Object catch (_) {
      // Silently ignore refresh errors
    }
  }
}
