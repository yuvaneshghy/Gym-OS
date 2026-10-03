import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../../data/pocketbase_client.dart';
import '../domain/payment.dart';

final paymentsRepositoryProvider = Provider<PaymentsRepository>((ref) {
  return PaymentsRepository(ref.watch(pocketBaseProvider));
});

final memberPaymentsProvider = FutureProvider.family.autoDispose<List<Payment>, String>((ref, memberId) async {
  final repo = ref.watch(paymentsRepositoryProvider);
  return repo.getPaymentsForMember(memberId);
});

class PaymentsRepository {
  PaymentsRepository(this._pb);
  final PocketBase _pb;

  Future<List<Payment>> getPaymentsForMember(String memberId) async {
    final res = await _pb.collection('payments').getFullList(
      filter: 'member="$memberId"',
      sort: '-date',
    );
    return res.map(Payment.fromRecord).toList();
  }

  Future<void> recordPayment({
    required String memberId,
    String? membershipId,
    required double amount,
    required String method,
    String? notes,
  }) async {
    final now = DateTime.now();
    // PocketBase dates must be UTC string
    String pbDate(DateTime d) => d.toUtc().toIso8601String().replaceFirst('T', ' ');

    await _pb.collection('payments').create(body: {
      'member': memberId,
      if (membershipId != null && membershipId.isNotEmpty) 'membership': membershipId,
      'amount': amount,
      'method': method,
      'notes': notes ?? '',
      'date': pbDate(now),
    });
  }
}
