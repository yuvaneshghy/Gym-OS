import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/config/tenant_config_repository.dart';
import '../../../core/theme/app_tokens.dart';
import '../../auth/data/auth_repository.dart';
import '../../payments/data/payments_repository.dart';
import '../data/members_repository.dart';
import '../domain/member.dart';

final currentMemberProvider = FutureProvider.autoDispose<Member?>((ref) async {
  final user = ref.watch(authRepositoryProvider).currentUser;
  if (user == null) return null;
  final repo = ref.watch(membersRepositoryProvider);
  final members = await repo.getMembers(perPage: 100);
  try {
    return members.firstWhere((m) => m.userId == user.id);
  } on Object catch (_) {
    return null;
  }
});

class MemberHomeScreen extends ConsumerWidget {
  const MemberHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memberAsync = ref.watch(currentMemberProvider);
    final currency = ref.watch(tenantConfigProvider).value?.currency ?? '₹';
    final theme = Theme.of(context);
    final tokens = context.tokens;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Dashboard'),
        centerTitle: false,
      ),
      body: memberAsync.when(
        data: (member) {
          if (member == null) {
            return const Center(child: Text('Member profile not found.'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref
                ..invalidate(currentMemberProvider)
                ..invalidate(memberMembershipsProvider(member.id))
                ..invalidate(memberPaymentsProvider(member.id));
            },
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                _buildDigitalIdCard(context, member, theme, tokens),
                const SizedBox(height: 32),
                _buildPlanSection(context, ref, member.id, theme, tokens),
                const SizedBox(height: 32),
                _buildPaymentsSection(context, ref, member.id, theme, tokens, currency),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildDigitalIdCard(BuildContext context, Member member, ThemeData theme, AppTokens tokens) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(tokens.cornerRadius * 1.5),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withAlpha(40),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: QrImageView(
              data: member.id,
              size: 200.0,
              backgroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            member.name,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'MEMBER ID: ${member.id.toUpperCase()}',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onPrimaryContainer.withAlpha(150),
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanSection(BuildContext context, WidgetRef ref, String memberId, ThemeData theme, AppTokens tokens) {
    final membershipsAsync = ref.watch(memberMembershipsProvider(memberId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'My Active Plan',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        membershipsAsync.when(
          data: (memberships) {
            final now = DateTime.now();
            final active = memberships.where((m) => now.isAfter(m.startDate) && now.isBefore(m.endDate)).toList();
            
            if (active.isEmpty) {
              return _buildEmptyCard(theme, tokens, 'No Active Plan', Icons.card_membership);
            }

            final current = active.first;
            final totalDays = current.endDate.difference(current.startDate).inDays;
            final daysPassed = now.difference(current.startDate).inDays;
            final daysRemaining = totalDays - daysPassed;
            final progress = (daysPassed / totalDays).clamp(0.0, 1.0);

            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(tokens.cornerRadius),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        current.expandPlan?.name ?? 'Active Plan',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$daysRemaining days left',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 12,
                      backgroundColor: theme.colorScheme.surface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Started: ${DateFormat.yMMMd().format(current.startDate)}',
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                      ),
                      Text(
                        'Ends: ${DateFormat.yMMMd().format(current.endDate)}',
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
          loading: () => const CircularProgressIndicator(),
          error: (e, st) => Text('Error: $e'),
        ),
      ],
    );
  }

  Widget _buildPaymentsSection(BuildContext context, WidgetRef ref, String memberId, ThemeData theme, AppTokens tokens, String currency) {
    final paymentsAsync = ref.watch(memberPaymentsProvider(memberId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Payments',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        paymentsAsync.when(
          data: (payments) {
            if (payments.isEmpty) {
              return _buildEmptyCard(theme, tokens, 'No Payment History', Icons.receipt_long);
            }

            final recent = payments.take(3).toList();
            return DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(tokens.cornerRadius),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recent.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final p = recent[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: theme.colorScheme.secondaryContainer,
                      child: Icon(Icons.attach_money, color: theme.colorScheme.onSecondaryContainer),
                    ),
                    title: Text('$currency${p.amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(DateFormat.yMMMd().format(p.date)),
                    trailing: Text(p.method.toUpperCase(), style: theme.textTheme.labelSmall),
                  );
                },
              ),
            );
          },
          loading: () => const CircularProgressIndicator(),
          error: (e, st) => Text('Error: $e'),
        ),
      ],
    );
  }

  Widget _buildEmptyCard(ThemeData theme, AppTokens tokens, String message, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withAlpha(100),
        borderRadius: BorderRadius.circular(tokens.cornerRadius),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: theme.colorScheme.outline),
          const SizedBox(height: 16),
          Text(
            message,
            style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.outline),
          ),
        ],
      ),
    );
  }
}
