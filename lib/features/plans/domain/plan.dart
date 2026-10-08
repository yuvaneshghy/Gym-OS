import 'package:pocketbase/pocketbase.dart';

class Plan {
  const Plan({
    required this.id,
    required this.name,
    required this.durationDays,
    required this.price,
    required this.created,
  });

  factory Plan.fromRecord(RecordModel record) {
    return Plan(
      id: record.id,
      name: record.getStringValue('name'),
      durationDays: record.getIntValue('duration_days'),
      price: record.getDoubleValue('price'),
      created: DateTime.parse(record.getStringValue('created')).toLocal(),
    );
  }

  final String id;
  final String name;
  final int durationDays;
  final double price;
  final DateTime created;
}
