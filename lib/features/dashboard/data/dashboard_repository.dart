import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../../data/pocketbase_client.dart';
import '../domain/dashboard_stats.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository(ref.watch(pocketBaseProvider));
});

final dashboardStatsProvider = FutureProvider.autoDispose<DashboardStats>((ref) async {
  return ref.watch(dashboardRepositoryProvider).getStats();
});

class DashboardRepository {
  DashboardRepository(this._pb);
  final PocketBase _pb;

  Future<DashboardStats> getStats() async {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final startOfMonth = DateTime(now.year, now.month, 1);

    String pbDate(DateTime d) => d.toUtc().toIso8601String().replaceFirst('T', ' ');

    final todayStr = pbDate(startOfToday);
    final monthStr = pbDate(startOfMonth);

    try {
      // 1. Total members
      final membersRes = await _pb.collection('members').getList(page: 1, perPage: 1);
      final totalMembers = membersRes.totalItems;

      // 2. Active members (memberships ending >= today)
      final activeRes = await _pb.collection('memberships').getList(page: 1, perPage: 1, filter: "end_date >= '$todayStr'");
      final activeMembers = activeRes.totalItems;

      // 3. Present today
      final attendanceRes = await _pb.collection('attendance').getList(page: 1, perPage: 1, filter: "check_in_time >= '$todayStr'");
      final presentToday = attendanceRes.totalItems;

      // 4. Monthly Revenue
      final paymentsRes = await _pb.collection('payments').getFullList(filter: "date >= '$monthStr'");
      double revenue = 0;
      for (final p in paymentsRes) {
        revenue += p.getDoubleValue('amount');
      }

      return DashboardStats(
        totalMembers: totalMembers,
        activeMembers: activeMembers,
        presentToday: presentToday,
        monthlyRevenue: revenue,
      );
    } on Object catch (_) {
      // Fallback if collections are empty or missing
      return const DashboardStats(
        totalMembers: 0,
        activeMembers: 0,
        presentToday: 0,
        monthlyRevenue: 0.0,
      );
    }
  }
}
