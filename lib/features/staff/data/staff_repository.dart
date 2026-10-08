import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../../data/pocketbase_client.dart';
import '../domain/staff_member.dart';

final staffRepositoryProvider = Provider<StaffRepository>((ref) {
  return StaffRepository(ref.watch(pocketBaseProvider));
});

final staffListProvider = FutureProvider.autoDispose<List<StaffMember>>((ref) async {
  return ref.watch(staffRepositoryProvider).getStaff();
});

class StaffRepository {
  StaffRepository(this._pb);
  final PocketBase _pb;

  Future<List<StaffMember>> getStaff() async {
    // Only fetch staff roles, ignore members and owners
    final res = await _pb.collection('users').getList(
      perPage: 100,
      filter: 'role = "manager" || role = "receptionist" || role = "trainer"',
      sort: '-created',
    );
    return res.items.map(StaffMember.fromRecord).toList();
  }

  Future<void> createStaff({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    await _pb.collection('users').create(body: {
      'email': email,
      'password': password,
      'passwordConfirm': password,
      'name': name,
      'role': role,
    });
  }

  Future<void> deleteStaff(String staffId) async {
    await _pb.collection('users').delete(staffId);
  }
}
