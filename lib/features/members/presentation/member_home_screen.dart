import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class MemberHomeScreen extends ConsumerWidget {
  const MemberHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 200,
              height: 200,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: const Center(child: Text('QR Code Here')),
            ),
            const SizedBox(height: 32),
            Text('Status: Active', style: Theme.of(context).textTheme.titleLarge),
            const Text('14 days remaining on your plan.'),
          ],
        ),
      ),
    );
  }
}
