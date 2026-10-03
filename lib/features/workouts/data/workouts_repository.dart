import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../../data/pocketbase_client.dart';
import '../domain/exercise.dart';
import '../domain/member_workout.dart';
import '../domain/workout_template.dart';

final workoutsRepositoryProvider = Provider<WorkoutsRepository>((ref) {
  return WorkoutsRepository(ref.watch(pocketBaseProvider));
});

final exercisesProvider = FutureProvider.autoDispose<List<Exercise>>((ref) async {
  final repo = ref.watch(workoutsRepositoryProvider);
  return repo.getExercises();
});

final workoutTemplatesProvider = FutureProvider.autoDispose<List<WorkoutTemplate>>((ref) async {
  final repo = ref.watch(workoutsRepositoryProvider);
  return repo.getTemplates();
});

final memberWorkoutsProvider = FutureProvider.family.autoDispose<List<MemberWorkout>, String>((ref, memberId) async {
  final repo = ref.watch(workoutsRepositoryProvider);
  return repo.getMemberWorkouts(memberId);
});

class WorkoutsRepository {
  WorkoutsRepository(this._pb);
  final PocketBase _pb;

  Future<List<Exercise>> getExercises() async {
    final records = await _pb.collection('exercises').getFullList(sort: 'name');
    return records.map((r) => Exercise.fromJson(r.toJson())).toList();
  }

  Future<Exercise> createExercise(Exercise exercise) async {
    final record = await _pb.collection('exercises').create(body: exercise.toJson());
    return Exercise.fromJson(record.toJson());
  }

  Future<List<WorkoutTemplate>> getTemplates() async {
    final records = await _pb.collection('workout_templates').getFullList(sort: '-created');
    return records.map((r) => WorkoutTemplate.fromJson(r.toJson())).toList();
  }

  Future<WorkoutTemplate> createTemplate(WorkoutTemplate template) async {
    final record = await _pb.collection('workout_templates').create(body: template.toJson());
    return WorkoutTemplate.fromJson(record.toJson());
  }

  Future<List<MemberWorkout>> getMemberWorkouts(String memberId) async {
    final records = await _pb.collection('member_workouts').getFullList(
      filter: 'member = "$memberId"',
      sort: '-date',
      expand: 'template',
    );
    return records.map((r) => MemberWorkout.fromJson(r.toJson())).toList();
  }

  Future<MemberWorkout> assignWorkout(MemberWorkout workout) async {
    final record = await _pb.collection('member_workouts').create(
      body: workout.toJson(),
      expand: 'template',
    );
    return MemberWorkout.fromJson(record.toJson());
  }

  Future<void> updateWorkoutStatus(String workoutId, String status, Map<String, dynamic> logData) async {
    await _pb.collection('member_workouts').update(workoutId, body: {
      'status': status,
      'log_data': logData,
    });
  }
}
