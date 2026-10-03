import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../attendance/data/attendance_repository.dart';
import '../data/dashboard_repository.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Overview', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  Text('Here is what is happening at your gym today.', 
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  statsAsync.when(
                    data: (stats) => GridView.count(
                      crossAxisCount: MediaQuery.of(context).size.width > 900 ? 4 : (MediaQuery.of(context).size.width > 600 ? 2 : 1),
                      shrinkWrap: true,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.5,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _StatCard(title: 'Total Members', value: '${stats.totalMembers}', icon: Icons.people),
                        _StatCard(title: 'Active Members', value: '${stats.activeMembers}', icon: Icons.how_to_reg, color: Colors.green),
                        _StatCard(title: 'Present Today', value: '${stats.presentToday}', icon: Icons.fitness_center, color: Colors.orange),
                        _StatCard(title: 'Revenue (Month)', value: '₹${stats.monthlyRevenue.toStringAsFixed(0)}', icon: Icons.currency_rupee, color: Colors.blue),
                      ],
                    ),
                    loading: () => const Padding(
                      padding: EdgeInsets.all(48.0),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (e, st) => Center(child: Text('Error loading stats: $e')),
                  ),
                  
                  const SizedBox(height: 48),
                  Text('Recent Activity', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  
                  Consumer(
                    builder: (context, ref, child) {
                      final attendanceAsync = ref.watch(todaysAttendanceProvider);
                      return attendanceAsync.when(
                        data: (records) {
                          if (records.isEmpty) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(32.0),
                                child: Text('No activity today.'),
                              ),
                            );
                          }
                          // Show only latest 5
                          final recent = records.take(5).toList();
                          return ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: recent.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final r = recent[index];
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
                                title: Text(r.expandMember?.name ?? 'Unknown Member', style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: const Text('Checked In'),
                                trailing: Text(
                                  '${r.checkInTime.hour.toString().padLeft(2, '0')}:${r.checkInTime.minute.toString().padLeft(2, '0')}',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.outline,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (e, st) => Center(child: Text('Error: $e')),
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

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title, 
    required this.value, 
    required this.icon, 
    this.color,
  });
  
  final String title;
  final String value;
  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final baseColor = color ?? Theme.of(context).colorScheme.primary;
    
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: baseColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: baseColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(title, 
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(value, 
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold, 
              color: Theme.of(context).colorScheme.onSurface
            ),
          ),
        ],
      ),
    );
  }
}
