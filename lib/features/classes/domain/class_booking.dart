import 'gym_class.dart';

class ClassBooking {
  const ClassBooking({
    required this.id,
    required this.classId,
    required this.memberId,
    required this.status,
    this.gymClass,
  });

  factory ClassBooking.fromJson(Map<String, dynamic> json) {
    return ClassBooking(
      id: json['id'] as String,
      classId: json['class'] as String,
      memberId: json['member'] as String,
      status: json['status'] as String,
      gymClass: json['expand']?['class'] != null 
          ? GymClass.fromJson(json['expand']['class'] as Map<String, dynamic>) 
          : null,
    );
  }

  final String id;
  final String classId;
  final String memberId;
  final String status;
  final GymClass? gymClass;

  Map<String, dynamic> toJson() => {
        'class': classId,
        'member': memberId,
        'status': status,
      };
}
