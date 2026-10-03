import 'package:pocketbase/pocketbase.dart';

class Payment {
  const Payment({
    required this.id,
    required this.memberId,
    this.membershipId,
    required this.amount,
    required this.method,
    required this.date,
    this.notes,
    required this.created,
  });

  final String id;
  final String memberId;
  final String? membershipId;
  final double amount;
  final String method;
  final DateTime date;
  final String? notes;
  final DateTime created;

  factory Payment.fromRecord(RecordModel record) {
    return Payment(
      id: record.id,
      memberId: record.getStringValue('member'),
      membershipId: record.getStringValue('membership').isEmpty ? null : record.getStringValue('membership'),
      amount: record.getDoubleValue('amount'),
      method: record.getStringValue('method'),
      date: DateTime.parse(record.getStringValue('date')).toLocal(),
      notes: record.getStringValue('notes'),
      created: DateTime.parse(record.getStringValue('created')).toLocal(),
    );
  }
}
