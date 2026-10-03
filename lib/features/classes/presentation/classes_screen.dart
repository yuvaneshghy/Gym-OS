import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_tokens.dart';
import '../data/classes_repository.dart';

class ClassesScreen extends ConsumerWidget {
  const ClassesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classesAsync = ref.watch(upcomingClassesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Classes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Open Class Builder
            },
          ),
        ],
      ),
      body: classesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (classes) {
          if (classes.isEmpty) {
            return Center(
              child: Text(
                'No upcoming classes.\nClick + to schedule one.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: classes.length,
            itemBuilder: (context, index) {
              final gymClass = classes[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(context.tokens.cornerRadius),
                ),
                child: ListTile(
                  title: Text(gymClass.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    '${DateFormat.yMMMd().format(gymClass.startTime)} at ${DateFormat.jm().format(gymClass.startTime)}\nCapacity: ${gymClass.capacity}',
                  ),
                  trailing: const Icon(Icons.event),
                  onTap: () {
                    // TODO: Manage attendees
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
