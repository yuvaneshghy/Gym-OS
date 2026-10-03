import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/tenant_config_repository.dart';
import '../../plans/data/plans_repository.dart';
import '../../plans/domain/plan.dart';
import '../data/members_repository.dart';
import '../domain/member.dart';

class AssignPlanDialog extends ConsumerStatefulWidget {
  const AssignPlanDialog({super.key, required this.member, required this.onAssigned});

  final Member member;
  final VoidCallback onAssigned;

  @override
  ConsumerState<AssignPlanDialog> createState() => _AssignPlanDialogState();
}

class _AssignPlanDialogState extends ConsumerState<AssignPlanDialog> {
  Plan? _selectedPlan;
  bool _isLoading = false;
  String? _error;

  Future<void> _submit() async {
    if (_selectedPlan == null) return;
    
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      await ref.read(membersRepositoryProvider).assignPlan(
        memberId: widget.member.id,
        planId: _selectedPlan!.id,
        durationDays: _selectedPlan!.durationDays,
      );
      
      widget.onAssigned();
      
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Plan assigned to ${widget.member.name}!')),
        );
      }
    } on Object catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final plansAsync = ref.watch(plansListProvider);
    final currency = ref.watch(tenantConfigProvider).value?.currency ?? '₹';

    return AlertDialog(
      title: Text('Assign Plan to ${widget.member.name}'),
      content: SizedBox(
        width: 400,
        child: plansAsync.when(
          data: (plans) {
            if (plans.isEmpty) {
              return const Text('No plans available. Please create a plan first.');
            }
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_error != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    color: Theme.of(context).colorScheme.errorContainer,
                    child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer)),
                  ),
                const Text('Select a Membership Plan:'),
                const SizedBox(height: 16),
                DropdownMenu<Plan>(
                  width: 350,
                  initialSelection: _selectedPlan,
                  onSelected: (plan) {
                    setState(() => _selectedPlan = plan);
                  },
                  dropdownMenuEntries: plans.map((p) => DropdownMenuEntry(
                    value: p,
                    label: '${p.name} - $currency${p.price.toStringAsFixed(2)} (${p.durationDays} Days)',
                  )).toList(),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, st) => Text('Error loading plans: $err'),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: (_isLoading || _selectedPlan == null) ? null : _submit,
          child: _isLoading 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Assign'),
        ),
      ],
    );
  }
}
