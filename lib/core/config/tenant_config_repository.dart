import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/pocketbase_client.dart';
import 'tenant_config.dart';

/// Repository that handles the low-level API and Cache ops.
final tenantConfigRepositoryProvider = Provider<TenantConfigRepository>((ref) {
  return TenantConfigRepository(
    ref.watch(pocketBaseProvider),
    ref.watch(sharedPreferencesProvider),
  );
});

class TenantConfigRepository {
  TenantConfigRepository(this._pb, this._prefs);
  final PocketBase _pb;
  final SharedPreferences _prefs;
  static const _cacheKey = 'tenant_config_cache';

  TenantConfig? getCachedConfig() {
    final cached = _prefs.getString(_cacheKey);
    if (cached != null) {
      try {
        return TenantConfig.fromJson(jsonDecode(cached) as Map<String, dynamic>);
      } on Object catch (_) {}
    }
    return null;
  }

  Future<TenantConfig> fetchFromNetwork() async {
    final record = await _pb.collection('app_config').getFirstListItem('', query: {'sort': '-updated'});
    final data = record.data;
    final logoFilename = record.getStringValue('logo');
    if (logoFilename.isNotEmpty) {
      data['logo_url'] = _pb.files.getUrl(record, logoFilename).toString();
    } else {
      data['logo_url'] = '';
    }
    await _prefs.setString(_cacheKey, jsonEncode(data));
    return TenantConfig.fromJson(data);
  }

  Future<void> updateConfig(TenantConfig newConfig) async {
    final record = await _pb.collection('app_config').getFirstListItem('', query: {'sort': '-updated'});
    await _pb.collection('app_config').update(record.id, body: newConfig.toJson());
    await _prefs.setString(_cacheKey, jsonEncode(newConfig.toJson()));
  }

  Future<void> uploadLogo(XFile file) async {
    final record = await _pb.collection('app_config').getFirstListItem('', query: {'sort': '-updated'});
    final bytes = await file.readAsBytes();
    final multipartFile = http.MultipartFile.fromBytes('logo', bytes, filename: file.name);
    await _pb.collection('app_config').update(record.id, files: [multipartFile]);
    await fetchFromNetwork(); // To refresh URL and cache
  }

  Future<void> cacheConfig(TenantConfig newConfig) async {
    await _prefs.setString(_cacheKey, jsonEncode(newConfig.toJson()));
  }
}

/// Provides a reactive stream of the TenantConfig.
final tenantConfigProvider = AsyncNotifierProvider<TenantConfigNotifier, TenantConfig>(TenantConfigNotifier.new);

class TenantConfigNotifier extends AsyncNotifier<TenantConfig> {
  @override
  Future<TenantConfig> build() async {
    final repo = ref.watch(tenantConfigRepositoryProvider);
    
    // Attempt network fetch but return cached immediately if available
    final cached = repo.getCachedConfig();
    
    // Fire and forget background network refresh
    // ignore: unawaited_futures
    _refreshFromNetwork();
    
    // If no cache, wait for network
    if (cached == null) {
      return await repo.fetchFromNetwork();
    }
    
    return cached;
  }

  Future<void> _refreshFromNetwork() async {
    final repo = ref.read(tenantConfigRepositoryProvider);
    try {
      final fresh = await repo.fetchFromNetwork();
      state = AsyncData(fresh);
    } on Object catch (_) {
      // Ignore background refresh errors
    }
  }

  Future<void> updateConfig(TenantConfig newConfig) async {
    final repo = ref.read(tenantConfigRepositoryProvider);
    
    // Optimistic UI update and cache
    state = AsyncData(newConfig);
    await repo.cacheConfig(newConfig); 
    
    try {
      await repo.updateConfig(newConfig);
    } catch (e, st) {
      // Revert if error? We'll just surface it.
      state = AsyncError(e, st);
      rethrow;
    }
  }
  
  Future<void> uploadLogo(XFile file) async {
    final repo = ref.read(tenantConfigRepositoryProvider);
    await repo.uploadLogo(file);
    await _refreshFromNetwork();
  }
}
