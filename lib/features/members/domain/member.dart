import 'package:pocketbase/pocketbase.dart';

class Member {
  const Member({
    required this.id,
    required this.userId,
    required this.name,
    required this.phone,
    required this.joinedOn,
  });

  factory Member.fromRecord(RecordModel record) {
    return Member(
      id: record.id,
      userId: record.getStringValue('user'),
      name: record.getStringValue('name'),
      phone: record.getStringValue('phone'),
      joinedOn: DateTime.tryParse(record.getStringValue('joined_on')) ?? DateTime.now(),
    );
  }

  final String id;
  final String userId;
  final String name;
  final String phone;
  final DateTime joinedOn;
}
