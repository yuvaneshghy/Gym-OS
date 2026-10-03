import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/members_repository.dart';
import 'add_member_dialog.dart';

class MembersDirectoryScreen extends ConsumerWidget {
  const MembersDirectoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(membersListProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Member Directory', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  Text('Manage all gym members and their plans.', 
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  membersAsync.when(
                    data: (members) {
                      if (members.isEmpty) {
                        return const Center(child: Text('No members found.'));
                      }
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: members.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final m = members[index];
                          return ListTile(
                            tileColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                            ),
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                              child: Icon(Icons.person, color: Theme.of(context).colorScheme.primary),
                            ),
                            title: Text(m.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(m.phone.isEmpty ? 'No Phone' : m.phone),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Profile view coming soon!')),
                              );
                            },
                          );
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, st) => Center(child: Text('Error: $e')),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog<void>(
            context: context,
            builder: (_) => const AddMemberDialog(),
          );
        },
        icon: const Icon(Icons.person_add),
        label: const Text('Add Member'),
      ),
    );
  }
}
