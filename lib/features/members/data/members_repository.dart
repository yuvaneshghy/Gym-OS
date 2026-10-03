import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../../data/pocketbase_client.dart';
import '../domain/member.dart';
import '../domain/membership.dart';

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

  Future<void> updateCurrentMember({
    required String memberId,
    required String userId,
    required String name,
    required String phone,
  }) async {
    // Update user auth record
    await _pb.collection('users').update(userId, body: {
      'name': name,
    });
    // Update member record
    await _pb.collection('members').update(memberId, body: {
      'name': name,
      'phone': phone,
    });
  }

  Future<Member?> getCurrentMember() async {
    final userId = _pb.authStore.record?.id;
    if (userId == null) return null;
    try {
      final res = await _pb.collection('members').getFirstListItem('user="$userId"');
      return Member.fromRecord(res);
    } on Object catch (_) {
      return null;
    }
  }

  Future<List<Membership>> getMemberships(String memberId) async {
    final res = await _pb.collection('memberships').getFullList(
      filter: 'member="$memberId"',
      sort: '-created',
      expand: 'plan',
    );
    return res.map(Membership.fromRecord).toList();
  }

  Future<void> assignPlan({
    required String memberId,
    required String planId,
    required int durationDays,
  }) async {
    final now = DateTime.now();
    final endDate = now.add(Duration(days: durationDays));
    
    // PocketBase dates must be UTC string
    String pbDate(DateTime d) => d.toUtc().toIso8601String().replaceFirst('T', ' ');

    await _pb.collection('memberships').create(body: {
      'member': memberId,
      'plan': planId,
      'start_date': pbDate(now),
      'end_date': pbDate(endDate),
    });
  }
}
