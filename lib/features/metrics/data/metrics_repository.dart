import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketbase/pocketbase.dart';
import '../../../data/pocketbase_client.dart';
import '../domain/metric.dart';

final metricsRepositoryProvider = Provider<MetricsRepository>((ref) {
  return MetricsRepository(ref.watch(pocketBaseProvider));
});

final memberMetricsProvider = FutureProvider.family.autoDispose<List<Metric>, String>((ref, memberId) async {
  final repo = ref.watch(metricsRepositoryProvider);
  return repo.getMemberMetrics(memberId);
});

class MetricsRepository {
  MetricsRepository(this._pb);
  final PocketBase _pb;

  Future<List<Metric>> getMemberMetrics(String memberId) async {
    final records = await _pb.collection('metrics').getFullList(
      filter: 'member = "$memberId"',
      sort: 'date', // Ascending order for charts
    );
    return records.map((r) => Metric.fromJson(r.toJson())).toList();
  }

  Future<Metric> logMetric(Metric metric) async {
    final record = await _pb.collection('metrics').create(body: metric.toJson());
    return Metric.fromJson(record.toJson());
  }

  Future<void> deleteMetric(String metricId) async {
    await _pb.collection('metrics').delete(metricId);
  }
}
