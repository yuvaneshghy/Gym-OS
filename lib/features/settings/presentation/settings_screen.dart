import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/tenant_config.dart';
import '../../../core/config/tenant_config_repository.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/theme_mode_provider.dart';
import '../../auth/data/auth_repository.dart';
import 'member_profile_settings.dart';
import 'superadmin_auth_dialog.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}
class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final currentConfig = ref.watch(tenantConfigProvider).value ?? const TenantConfig();
    return Scaffold(
      body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Settings', style: Theme.of(context).textTheme.headlineMedium),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Text('App Preferences', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    Consumer(
                      builder: (context, ref, child) {
                        final currentMode = ref.watch(themeModeProvider);
                        return SegmentedButton<ThemeMode>(
                          segments: const [
                            ButtonSegment(value: ThemeMode.system, label: Text('System'), icon: Icon(Icons.brightness_auto)),
                            ButtonSegment(value: ThemeMode.light, label: Text('Light'), icon: Icon(Icons.light_mode)),
                            ButtonSegment(value: ThemeMode.dark, label: Text('Dark'), icon: Icon(Icons.dark_mode)),
                          ],
                          selected: {currentMode},
                          onSelectionChanged: (Set<ThemeMode> newSelection) {
                            ref.read(themeModeProvider.notifier).setMode(newSelection.first);
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                    if (ref.watch(authRepositoryProvider).currentRole == 'owner') ...[
                      Text('Team Management', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 16),
                      ListTile(
                        tileColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(context.tokens.cornerRadius),
                          side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                        ),
                        leading: const Icon(Icons.group),
                        title: const Text('Manage Staff & Employees', style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: const Text('Create accounts for trainers and managers'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          context.go('/settings/staff');
                        },
                      ),
                      const SizedBox(height: 32),
                      Text('Advanced Settings (Locked)', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 16),
                      Text(
                        'Core gym configuration and branding are locked and managed by the platform administrators.',
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: () {
                          showDialog<void>(
                            context: context,
                            builder: (_) => const SuperadminAuthDialog(),
                          );
                        },
                        icon: const Icon(Icons.admin_panel_settings),
                        label: const Text('Superuser Login'),
                      ),
                      const SizedBox(height: 32),
                    ] else ...[
                      const MemberProfileSettings(),
                    ],
                    // Shared view for Contact Info
                    const SizedBox(height: 32),
                    Text('Gym Contact Info', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    Card(
                      elevation: 0,
                      color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(100),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(context.tokens.cornerRadius),
                        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (currentConfig.gymName.isNotEmpty)
                              ListTile(
                                leading: const Icon(Icons.fitness_center),
                                title: Text(currentConfig.gymName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                contentPadding: EdgeInsets.zero,
                              ),
                            if (currentConfig.gymPhone.isNotEmpty)
                              ListTile(
                                leading: const Icon(Icons.phone),
                                title: Text(currentConfig.gymPhone),
                                contentPadding: EdgeInsets.zero,
                              ),
                            if (currentConfig.gymEmail.isNotEmpty)
                              ListTile(
                                leading: const Icon(Icons.email),
                                title: Text(currentConfig.gymEmail),
                                contentPadding: EdgeInsets.zero,
                              ),
                            if (currentConfig.gymAddress.isNotEmpty)
                              ListTile(
                                leading: const Icon(Icons.location_on),
                                title: Text(currentConfig.gymAddress),
                                contentPadding: EdgeInsets.zero,
                              ),
                          ],
                        ),
                      ),
                    ),
// Shared view moved up
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          ],
        ),
    );
  }
}
