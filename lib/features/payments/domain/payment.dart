import 'package:pocketbase/pocketbase.dart';

class Payment {
  const Payment({
    required this.id,
    required this.memberId,
    this.membershipId,
    required this.amount,
    this.gstAmount,
    this.taxRate,
    required this.method,
    required this.date,
    this.notes,
    required this.created,
  });

  factory Payment.fromRecord(RecordModel record) {
    return Payment(
      id: record.id,
      memberId: record.getStringValue('member'),
      membershipId: record.getStringValue('membership').isEmpty ? null : record.getStringValue('membership'),
      amount: record.getDoubleValue('amount'),
      gstAmount: record.getDoubleValue('gst_amount'),
      taxRate: record.getDoubleValue('tax_rate'),
      method: record.getStringValue('method'),
      date: DateTime.parse(record.getStringValue('date')).toLocal(),
      notes: record.getStringValue('notes'),
      created: DateTime.parse(record.getStringValue('created')).toLocal(),
    );
  }

  final String id;
  final String memberId;
  final String? membershipId;
  final double amount;
  final double? gstAmount;
  final double? taxRate;
  final String method;
  final DateTime date;
  final String? notes;
  final DateTime created;
}
