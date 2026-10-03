import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../payments/data/payments_repository.dart';
import '../../payments/presentation/record_payment_dialog.dart';
import '../data/members_repository.dart';
import '../domain/member.dart';
import '../domain/membership.dart';
import 'assign_plan_dialog.dart';

final memberProfileProvider = FutureProvider.family.autoDispose<Member?, String>((ref, id) async {
  final repo = ref.watch(membersRepositoryProvider);
  final members = await repo.getMembers(perPage: 100);
  try {
    return members.firstWhere((m) => m.id == id);
  } on Object catch (_) {
    return null;
  }
});

final memberMembershipsProvider = FutureProvider.family.autoDispose<List<Membership>, String>((ref, memberId) async {
  final repo = ref.watch(membersRepositoryProvider);
  return repo.getMemberships(memberId);
});

class MemberProfileScreen extends ConsumerWidget {
  const MemberProfileScreen({super.key, required this.memberId});
  final String memberId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memberAsync = ref.watch(memberProfileProvider(memberId));
    final membershipsAsync = ref.watch(memberMembershipsProvider(memberId));
    final paymentsAsync = ref.watch(memberPaymentsProvider(memberId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/members'),
        ),
        title: const Text('Member Profile'),
      ),
      body: memberAsync.when(
        data: (member) {
          if (member == null) {
            return const Center(child: Text('Member not found.'));
          }

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        child: Text(
                          member.name.substring(0, 1).toUpperCase(),
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(member.name, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                      Text(member.phone, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.outline)),
                      const SizedBox(height: 8),
                      Text('Joined ${member.joinedOn.year}-${member.joinedOn.month.toString().padLeft(2, '0')}-${member.joinedOn.day.toString().padLeft(2, '0')}', style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
              ),
              
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Text('Active Memberships', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
              ),
              
              membershipsAsync.when(
                data: (memberships) {
                  if (memberships.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(child: Text('No active memberships.')),
                      ),
                    );
                  }
                  
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final m = memberships[index];
                        final plan = m.expandPlan;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                          child: Card(
                            elevation: 0,
                            color: m.isActive 
                              ? Theme.of(context).colorScheme.primaryContainer.withAlpha(50)
                              : Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: m.isActive ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outlineVariant,
                              ),
                            ),
                            child: ListTile(
                              title: Text(plan?.name ?? 'Unknown Plan', style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('${m.startDate.year}-${m.startDate.month.toString().padLeft(2, '0')}-${m.startDate.day.toString().padLeft(2, '0')} to ${m.endDate.year}-${m.endDate.month.toString().padLeft(2, '0')}-${m.endDate.day.toString().padLeft(2, '0')}'),
                              trailing: Chip(
                                label: Text(m.isActive ? 'ACTIVE' : 'EXPIRED'),
                                backgroundColor: m.isActive ? Colors.green.withAlpha(50) : Colors.red.withAlpha(50),
                                side: BorderSide.none,
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: memberships.length,
                    ),
                  );
                },
                loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())),
                error: (err, st) => SliverToBoxAdapter(child: Center(child: Text('Error: $err'))),
              ),
              
              
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Text('Payment History', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
              ),

              paymentsAsync.when(
                data: (payments) {
                  if (payments.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(child: Text('No payments recorded.')),
                      ),
                    );
                  }
                  
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final p = payments[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                          child: Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                            ),
                            child: ListTile(
                              leading: const Icon(Icons.receipt_long),
                              title: Text('\$${p.amount.toStringAsFixed(2)} via ${p.method.toUpperCase()}'),
                              subtitle: Text('${p.date.year}-${p.date.month.toString().padLeft(2, '0')}-${p.date.day.toString().padLeft(2, '0')}${p.notes?.isNotEmpty == true ? ' • ${p.notes}' : ''}'),
                            ),
                          ),
                        );
                      },
                      childCount: payments.length,
                    ),
                  );
                },
                loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())),
                error: (err, st) => SliverToBoxAdapter(child: Center(child: Text('Error: $err'))),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: memberAsync.hasValue && memberAsync.value != null 
        ? Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              FloatingActionButton.small(
                heroTag: 'record_payment',
                onPressed: () {
                  showDialog<void>(
                    context: context,
                    builder: (_) => RecordPaymentDialog(
                      memberId: memberAsync.value!.id,
                      onRecorded: () {
                        ref.invalidate(memberPaymentsProvider(memberId));
                      },
                    ),
                  );
                },
                child: const Icon(Icons.attach_money),
              ),
              const SizedBox(height: 8),
              FloatingActionButton.extended(
                heroTag: 'assign_plan',
                onPressed: () {
                  showDialog<void>(
                    context: context,
                    builder: (_) => AssignPlanDialog(
                      member: memberAsync.value!,
                      onAssigned: () {
                        ref.invalidate(memberMembershipsProvider(memberId));
                      },
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Assign Plan'),
              ),
            ],
          )
        : null,
    );
  }
}
