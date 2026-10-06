import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../members/data/members_repository.dart';
import '../../members/domain/member.dart';
import '../data/workouts_repository.dart';
import '../domain/member_workout.dart';
import '../domain/workout_template.dart';

class AssignWorkoutDialog extends ConsumerStatefulWidget {
  const AssignWorkoutDialog({
    super.key,
    required this.template,
  });

  final WorkoutTemplate template;

  @override
  ConsumerState<AssignWorkoutDialog> createState() => _AssignWorkoutDialogState();
}

class _AssignWorkoutDialogState extends ConsumerState<AssignWorkoutDialog> {
  Member? _selectedMember;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  Future<void> _submit() async {
    if (_selectedMember == null) return;
    
    setState(() => _isLoading = true);
    try {
      await ref.read(workoutsRepositoryProvider).assignWorkout(
        MemberWorkout(
          id: '', // PocketBase generates this
          memberId: _selectedMember!.id,
          templateId: widget.template.id,
          date: _selectedDate,
          status: 'pending',
        ),
      );
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Assigned to ${_selectedMember!.name} successfully')),
        );
      }
    } on Object catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to assign: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(membersListProvider);

    return AlertDialog(
      title: Text('Assign: ${widget.template.name}'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            membersAsync.when(
              data: (members) {
                return DropdownMenu<Member>(
                  width: double.infinity,
                  label: const Text('Select Member'),
                  onSelected: (val) {
                    setState(() => _selectedMember = val);
                  },
                  dropdownMenuEntries: members.map((m) {
                    return DropdownMenuEntry(value: m, label: m.name);
                  }).toList(),
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (err, st) => Text('Error loading members: $err'),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Date'),
              subtitle: Text('${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now().subtract(const Duration(days: 1)),
                  lastDate: DateTime.now().add(const Duration(days: 90)),
                );
                if (date != null) {
                  setState(() => _selectedDate = date);
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: (_isLoading || _selectedMember == null) ? null : _submit,
          child: _isLoading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Assign'),
        ),
      ],
    );
  }
}
