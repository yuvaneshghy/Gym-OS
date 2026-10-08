import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/tenant_config_repository.dart';
import '../../../core/theme/app_tokens.dart';

import '../data/plans_repository.dart';
import 'add_plan_dialog.dart';

class PlansScreen extends ConsumerWidget {
  const PlansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plansAsync = ref.watch(plansListProvider);
    final currency = ref.watch(tenantConfigProvider).value?.currency ?? '₹';


    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text('Membership Plans', style: Theme.of(context).textTheme.headlineMedium),
            ),
          ),
          plansAsync.when(
            data: (plans) {
              if (plans.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(48.0),
                    child: Center(
                      child: Text('No plans created yet.', style: Theme.of(context).textTheme.bodyLarge),
                    ),
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 300,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.2,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final plan = plans[index];
                      return Card(
                        elevation: 0,
                        color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(100),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(context.tokens.cornerRadius),
                          side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(child: Text(plan.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold))),
                                  PopupMenuButton<String>(
                                    onSelected: (val) async {
                                      if (val == 'edit') {
                                        await showDialog<void>(
                                          context: context,
                                          builder: (_) => AddPlanDialog(existingPlan: plan),
                                        );
                                      } else if (val == 'delete') {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            title: const Text('Delete Plan?'),
                                            content: const Text('Are you sure you want to delete this plan? Active memberships will not be deleted, but no new members can be assigned.'),
                                            actions: [
                                              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                              FilledButton(
                                                style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
                                                onPressed: () => Navigator.pop(ctx, true), 
                                                child: const Text('Delete'),
                                              ),
                                            ],
                                          ),
                                        );
                                        if (confirm == true) {
                                          await ref.read(plansRepositoryProvider).deletePlan(plan.id);
                                          ref.invalidate(plansListProvider);
                                        }
                                      }
                                    },
                                    itemBuilder: (_) => [
                                      const PopupMenuItem(value: 'edit', child: Text('Edit Plan')),
                                      const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
                                    ],
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Text('${plan.durationDays} Days', style: Theme.of(context).textTheme.bodyLarge),
                              const SizedBox(height: 8),
                              Text('$currency${plan.price.toStringAsFixed(2)}', style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w900,
                              )),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: plans.length,
                  ),
                ),
              );
            },
            loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
            error: (err, st) => SliverFillRemaining(child: Center(child: Text('Error: $err'))),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog<void>(
            context: context,
            builder: (_) => const AddPlanDialog(),
          );
        },
        icon: const Icon(Icons.add_card),
        label: const Text('Create Plan'),
      ),
    );
  }
}
