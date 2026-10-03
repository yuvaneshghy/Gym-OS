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
}
