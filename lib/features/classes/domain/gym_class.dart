class GymClass {
  const GymClass({
    required this.id,
    required this.name,
    this.instructorId,
    required this.startTime,
    required this.endTime,
    required this.capacity,
  });

  factory GymClass.fromJson(Map<String, dynamic> json) {
    return GymClass(
      id: json['id'] as String,
      name: json['name'] as String,
      instructorId: json['instructor'] as String?,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      capacity: json['capacity'] as int,
    );
  }

  final String id;
  final String name;
  final String? instructorId;
  final DateTime startTime;
  final DateTime endTime;
  final int capacity;

  Map<String, dynamic> toJson() => {
        'name': name,
        if (instructorId != null) 'instructor': instructorId,
        'start_time': startTime.toIso8601String(),
        'end_time': endTime.toIso8601String(),
        'capacity': capacity,
      };
}
