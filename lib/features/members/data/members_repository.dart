import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../../data/pocketbase_client.dart';
import '../domain/member.dart';

final membersRepositoryProvider = Provider<MembersRepository>((ref) {
  return MembersRepository(ref.watch(pocketBaseProvider));
});

final membersListProvider = FutureProvider.autoDispose<List<Member>>((ref) async {
  return ref.watch(membersRepositoryProvider).getMembers();
});

class MembersRepository {
  MembersRepository(this._pb);
  final PocketBase _pb;

  Future<List<Member>> getMembers({int page = 1, int perPage = 50}) async {
    final res = await _pb.collection('members').getList(
      page: page, 
      perPage: perPage,
      sort: '-created',
    );
    return res.items.map(Member.fromRecord).toList();
  }

  Future<void> createMember({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    // 1. Create auth user
    final userRecord = await _pb.collection('users').create(body: {
      'email': email,
      'password': password,
      'passwordConfirm': password,
      'name': name,
      'role': 'member',
    });

    // 2. Create linked member profile
    await _pb.collection('members').create(body: {
      'user': userRecord.id,
      'name': name,
      'phone': phone,
      'joined_on': DateTime.now().toUtc().toIso8601String().replaceFirst('T', ' '),
    });
  }
}
