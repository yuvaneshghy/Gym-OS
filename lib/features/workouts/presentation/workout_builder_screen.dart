import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_tokens.dart';
import '../../auth/data/auth_repository.dart';
import '../data/workouts_repository.dart';
import '../domain/exercise.dart';
import '../domain/workout_template.dart';

class WorkoutBuilderScreen extends ConsumerStatefulWidget {
  const WorkoutBuilderScreen({super.key});

  @override
  ConsumerState<WorkoutBuilderScreen> createState() => _WorkoutBuilderScreenState();
}

class _WorkoutBuilderScreenState extends ConsumerState<WorkoutBuilderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  final List<RoutineItem> _routine = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _addExercise(Exercise exercise) {
    setState(() {
      _routine.add(RoutineItem(
        exerciseId: exercise.id,
        sets: 3,
        reps: '10',
        restSeconds: 60,
        exercise: exercise,
      ));
    });
  }

  Future<void> _saveWorkout() async {
    if (!_formKey.currentState!.validate()) return;
    if (_routine.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Add at least one exercise to the routine'),
          backgroundColor: context.tokens.dangerColor,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final trainerId = ref.read(authRepositoryProvider).currentUser!.id;
      final template = WorkoutTemplate(
        id: '', // PocketBase will generate
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        trainerId: trainerId,
        routineData: _routine,
      );

      await ref.read(workoutsRepositoryProvider).createTemplate(template);
      ref.invalidate(workoutTemplatesProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Workout Template Created!')),
        );
        context.pop();
      }
    } on Object catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: context.tokens.dangerColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final exercisesAsync = ref.watch(exercisesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Builder'),
        actions: [
          if (_isLoading)
            const Center(child: Padding(padding: EdgeInsets.only(right: 16), child: CircularProgressIndicator()))
          else
            FilledButton.icon(
              onPressed: _saveWorkout,
              icon: const Icon(Icons.save),
              label: const Text('Save'),
            ).padding(const EdgeInsets.only(right: 16)),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Sidebar: Exercise Library
          Expanded(
            child: ColoredBox(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('Exercise Library', style: theme.textTheme.titleMedium),
                  ),
                  Expanded(
                    child: exercisesAsync.when(
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (err, _) => Center(child: Text('Error: $err')),
                      data: (exercises) {
                        if (exercises.isEmpty) {
                          return Center(
                            child: FilledButton.tonal(
                              onPressed: () {
                                // TODO: Show Add Exercise Dialog
                              },
                              child: const Text('Add First Exercise'),
                            ),
                          );
                        }
                        return ListView.builder(
                          itemCount: exercises.length,
                          itemBuilder: (context, index) {
                            final exercise = exercises[index];
                            return ListTile(
                              title: Text(exercise.name),
                              subtitle: Text(exercise.bodyPart.toUpperCase()),
                              trailing: IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                color: theme.colorScheme.primary,
                                onPressed: () => _addExercise(exercise),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Right Area: The Routine Canvas
          Expanded(
            flex: 2,
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Workout Name (e.g. Push Day A)'),
                    style: theme.textTheme.headlineSmall,
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Description (Optional)'),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 32),
                  Text('Routine', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 16),
                  
                  if (_routine.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(context.tokens.cornerRadius),
                        border: Border.all(color: theme.dividerColor),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Empty Routine\nAdd exercises from the library on the left.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                      ),
                    )
                  else
                    ReorderableListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _routine.length,
                      onReorderItem: (oldIndex, newIndex) {
                        setState(() {
                          final item = _routine.removeAt(oldIndex);
                          _routine.insert(newIndex, item);
                        });
                      },
                      itemBuilder: (context, index) {
                        final item = _routine[index];
                        return Card(
                          key: ValueKey('${item.exerciseId}_$index'),
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(context.tokens.cornerRadius),
                            side: BorderSide(color: theme.colorScheme.outlineVariant),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                const Icon(Icons.drag_handle, color: Colors.grey),
                                const SizedBox(width: 16),
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item.exercise?.name ?? 'Unknown Exercise', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      Text(item.exercise?.bodyPart.toUpperCase() ?? '', style: theme.textTheme.bodySmall),
                                    ],
                                  ),
                                ),
                                // Sets input
                                Expanded(
                                  child: TextFormField(
                                    initialValue: item.sets.toString(),
                                    decoration: const InputDecoration(labelText: 'Sets'),
                                    keyboardType: TextInputType.number,
                                    onChanged: (v) => _routine[index] = _routine[index].copyWith(sets: int.tryParse(v) ?? 3),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Reps input
                                Expanded(
                                  child: TextFormField(
                                    initialValue: item.reps,
                                    decoration: const InputDecoration(labelText: 'Reps (e.g. 8-12)'),
                                    onChanged: (v) => _routine[index] = _routine[index].copyWith(reps: v),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Rest input
                                Expanded(
                                  child: TextFormField(
                                    initialValue: item.restSeconds?.toString() ?? '60',
                                    decoration: const InputDecoration(labelText: 'Rest (s)'),
                                    keyboardType: TextInputType.number,
                                    onChanged: (v) => _routine[index] = _routine[index].copyWith(restSeconds: int.tryParse(v)),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    setState(() {
                                      _routine.removeAt(index);
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

extension PaddingExt on Widget {
  Widget padding(EdgeInsetsGeometry p) => Padding(padding: p, child: this);
}

extension RoutineItemCopy on RoutineItem {
  RoutineItem copyWith({
    String? exerciseId,
    int? sets,
    String? reps,
    int? restSeconds,
    Exercise? exercise,
  }) {
    return RoutineItem(
      exerciseId: exerciseId ?? this.exerciseId,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      restSeconds: restSeconds ?? this.restSeconds,
      exercise: exercise ?? this.exercise,
    );
  }
}
