import 'exercise.dart';

class RoutineItem {
  const RoutineItem({
    required this.exerciseId,
    required this.sets,
    required this.reps,
    this.restSeconds,
    this.exercise, // Optional expanded data
  });

  factory RoutineItem.fromJson(Map<String, dynamic> json) {
    return RoutineItem(
      exerciseId: json['exerciseId'] as String,
      sets: json['sets'] as int,
      reps: json['reps'] as String,
      restSeconds: json['restSeconds'] as int?,
      exercise: json['expand']?['exerciseId'] != null 
          ? Exercise.fromJson(json['expand']['exerciseId'] as Map<String, dynamic>) 
          : null,
    );
  }

  final String exerciseId;
  final int sets;
  final String reps;
  final int? restSeconds;
  final Exercise? exercise;

  Map<String, dynamic> toJson() => {
        'exerciseId': exerciseId,
        'sets': sets,
        'reps': reps,
        if (restSeconds != null) 'restSeconds': restSeconds,
      };
}

class WorkoutTemplate {
  const WorkoutTemplate({
    required this.id,
    required this.name,
    this.description,
    required this.trainerId,
    required this.routineData,
  });

  factory WorkoutTemplate.fromJson(Map<String, dynamic> json) {
    return WorkoutTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      trainerId: json['trainer'] as String,
      routineData: (json['routine_data'] as List<dynamic>?)
              ?.map((e) => RoutineItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  final String id;
  final String name;
  final String? description;
  final String trainerId;
  final List<RoutineItem> routineData;

  Map<String, dynamic> toJson() => {
        'name': name,
        if (description != null) 'description': description,
        'trainer': trainerId,
        'routine_data': routineData.map((e) => e.toJson()).toList(),
      };
}
