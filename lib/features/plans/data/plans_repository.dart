import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../../data/pocketbase_client.dart';
import '../domain/plan.dart';

final plansRepositoryProvider = Provider<PlansRepository>((ref) {
  return PlansRepository(ref.watch(pocketBaseProvider));
});

final plansListProvider = FutureProvider.autoDispose<List<Plan>>((ref) async {
  final repo = ref.watch(plansRepositoryProvider);
  return repo.getPlans();
});

class PlansRepository {
  PlansRepository(this._pb);
  final PocketBase _pb;

  Future<List<Plan>> getPlans() async {
    final res = await _pb.collection('plans').getFullList(sort: 'price');
    return res.map(Plan.fromRecord).toList();
  }

  Future<void> createPlan({
    required String name,
    required int durationDays,
    required double price,
  }) async {
    await _pb.collection('plans').create(body: {
      'name': name,
      'duration_days': durationDays,
      'price': price,
    });
  }
}
