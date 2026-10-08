import 'package:pocketbase/pocketbase.dart';

import '../../plans/domain/plan.dart';

class Membership {
  const Membership({
    required this.id,
    required this.memberId,
    required this.planId,
    required this.startDate,
    required this.endDate,
    required this.created,
    this.expandPlan,
  });

  factory Membership.fromRecord(RecordModel record) {
    Plan? plan;
    try {
      final plans = record.getListValue<RecordModel>('expand.plan');
      if (plans.isNotEmpty) {
        plan = Plan.fromRecord(plans.first);
      }
    } on Object catch (_) {}

    return Membership(
      id: record.id,
      memberId: record.getStringValue('member'),
      planId: record.getStringValue('plan'),
      startDate: DateTime.parse(record.getStringValue('start_date')).toLocal(),
      endDate: DateTime.parse(record.getStringValue('end_date')).toLocal(),
      created: DateTime.parse(record.getStringValue('created')).toLocal(),
      expandPlan: plan,
    );
  }

  final String id;
  final String memberId;
  final String planId;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime created;
  final Plan? expandPlan;

  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate);
  }
}
