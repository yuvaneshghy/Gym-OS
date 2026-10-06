import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_tokens.dart';
import '../data/workouts_repository.dart';
import '../domain/member_workout.dart';

class ActiveWorkoutScreen extends ConsumerStatefulWidget {
  const ActiveWorkoutScreen({super.key, required this.workout});
  final MemberWorkout workout;

  @override
  ConsumerState<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends ConsumerState<ActiveWorkoutScreen> {
  bool _isLoading = false;

  Future<void> _completeWorkout() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(workoutsRepositoryProvider).updateWorkoutStatus(
        widget.workout.id,
        'completed',
        {'notes': 'Completed via fast track'},
      );
      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Workout marked as completed! 🚀')),
        );
      }
    } on Object catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final template = widget.workout.template;
    final theme = Theme.of(context);

    if (template == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Workout')),
        body: const Center(child: Text('Custom workouts not fully supported yet.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(template.name),
        actions: [
          if (widget.workout.status != 'completed')
            TextButton.icon(
              onPressed: _isLoading ? null : _completeWorkout,
              icon: _isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.check),
              label: const Text('FINISH'),
            ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: template.routineData.length,
        itemBuilder: (context, index) {
          final exercise = template.routineData[index];
          final sets = exercise.sets;
          final reps = exercise.reps;
          
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(context.tokens.cornerRadius),
              side: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Exercise ${index + 1}', style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.primary)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Target: $sets sets x $reps reps',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      // Ideally we have input fields here
                      const Icon(Icons.edit_note, color: Colors.grey),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
