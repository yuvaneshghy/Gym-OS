import 'package:pocketbase/pocketbase.dart';

class StaffMember {
  const StaffMember({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.created,
  });

  factory StaffMember.fromRecord(RecordModel record) {
    return StaffMember(
      id: record.id,
      name: record.getStringValue('name'),
      email: record.getStringValue('email'),
      role: record.getStringValue('role'),
      created: DateTime.parse(record.getStringValue('created')).toLocal(),
    );
  }

  final String id;
  final String name;
  final String email;
  final String role;
  final DateTime created;
}
