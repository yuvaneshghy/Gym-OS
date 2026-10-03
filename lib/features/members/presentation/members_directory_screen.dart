import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_tokens.dart';

import '../data/members_repository.dart';
import 'add_member_dialog.dart';

class MembersDirectoryScreen extends ConsumerStatefulWidget {
  const MembersDirectoryScreen({super.key});

  @override
  ConsumerState<MembersDirectoryScreen> createState() => _MembersDirectoryScreenState();
}

class _MembersDirectoryScreenState extends ConsumerState<MembersDirectoryScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by name or phone...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(context.tokens.cornerRadius)),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) => setState(() => _searchQuery = value),
                  ),
                  const SizedBox(height: 24),
                  
                  membersAsync.when(
                    data: (members) {
                      final filteredMembers = members.where((m) {
                        final query = _searchQuery.toLowerCase();
                        return m.name.toLowerCase().contains(query) || m.phone.contains(query);
                      }).toList();

                      if (filteredMembers.isEmpty) {
                        return const Center(child: Text('No members found.'));
                      }
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredMembers.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final m = filteredMembers[index];
                          return ListTile(
                            tileColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(context.tokens.cornerRadius),
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
                              context.go('/members/${m.id}');
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
