import 'workout_template.dart';

class MemberWorkout {
  const MemberWorkout({
    required this.id,
    required this.memberId,
    this.templateId,
    this.assignedById,
    required this.date,
    required this.status,
    this.logData,
    this.template, // Expanded
  });

  factory MemberWorkout.fromJson(Map<String, dynamic> json) {
    return MemberWorkout(
      id: json['id'] as String,
      memberId: json['member'] as String,
      templateId: json['template'] as String?,
      assignedById: json['assigned_by'] as String?,
      date: DateTime.parse(json['date'] as String),
      status: json['status'] as String,
      logData: json['log_data'] as Map<String, dynamic>?,
      template: json['expand']?['template'] != null 
          ? WorkoutTemplate.fromJson(json['expand']['template'] as Map<String, dynamic>) 
          : null,
    );
  }

  final String id;
  final String memberId;
  final String? templateId;
  final String? assignedById;
  final DateTime date;
  final String status;
  final Map<String, dynamic>? logData;
  final WorkoutTemplate? template;

  Map<String, dynamic> toJson() => {
        'member': memberId,
        if (templateId != null) 'template': templateId,
        if (assignedById != null) 'assigned_by': assignedById,
        'date': date.toIso8601String(),
        'status': status,
        if (logData != null) 'log_data': logData,
      };
}
