import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import 'package:qr_flutter/qr_flutter.dart';
import '../../auth/data/auth_repository.dart';
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
    
    return Scaffold(
      appBar: AppBar(title: const Text('My Digital ID')),
      body: memberAsync.when(
        data: (member) {
          if (member == null) {
            return const Center(child: Text('Member profile not found.'));
          }
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(20),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: QrImageView(
                    data: member.id,
                    size: 250.0,
                    backgroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),
                Text(member.name, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Scan this at the front desk to check in', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.outline)),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
