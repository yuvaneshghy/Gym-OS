import 'package:pocketbase/pocketbase.dart';

import '../../members/domain/member.dart';

class AttendanceRecord {
  const AttendanceRecord({
    required this.id,
    required this.memberId,
    required this.checkInTime,
    required this.created,
    this.expandMember,
  });

  factory AttendanceRecord.fromRecord(RecordModel record) {
    Member? member;
    try {
      final members = record.getListValue<RecordModel>('expand.member');
      if (members.isNotEmpty) {
        member = Member.fromRecord(members.first);
      }
    } on Object catch (_) {}

    return AttendanceRecord(
      id: record.id,
      memberId: record.getStringValue('member'),
      checkInTime: DateTime.parse(record.getStringValue('check_in_time')).toLocal(),
      created: DateTime.parse(record.getStringValue('created')).toLocal(),
      expandMember: member,
    );
  }

  final String id;
  final String memberId;
  final DateTime checkInTime;
  final DateTime created;
  final Member? expandMember;
}
