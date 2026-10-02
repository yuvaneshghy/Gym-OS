import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../../data/pocketbase_client.dart';

/// Exposes the AuthRepository.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(pocketBaseProvider));
});

/// Exposes the currently logged-in user model (if any), re-evaluating when auth state changes.
final authStateProvider = StreamProvider<RecordModel?>((ref) {
  final pb = ref.watch(pocketBaseProvider);
  // Yield initial state
  return Stream.value(pb.authStore.record)
      .concatWith([
    pb.authStore.onChange.map((e) => e.record)
  ]);
});

extension StreamExtension<T> on Stream<T> {
  Stream<T> concatWith(Iterable<Stream<T>> others) async* {
    yield* this;
    for (final other in others) {
      yield* other;
    }
  }
}

class AuthRepository {
  AuthRepository(this._pb);

  final PocketBase _pb;

  bool get isAuthenticated => _pb.authStore.isValid;
  
  String? get currentRole => _pb.authStore.record?.getStringValue('role');

  Future<void> login(String email, String password) async {
    await _pb.collection('users').authWithPassword(email, password);
  }

  void logout() {
    _pb.authStore.clear();
  }
}
