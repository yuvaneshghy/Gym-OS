import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/data/auth_repository.dart';
import '../config/tenant_config.dart';
import '../config/tenant_config_repository.dart';

class AppLayout extends ConsumerWidget {
  const AppLayout({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final role = ref.watch(authRepositoryProvider).currentRole;
    final configAsync = ref.watch(tenantConfigProvider);
    final config = configAsync.value ?? const TenantConfig();
    
    // Build top dock
    final topDock = Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withAlpha(240),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.outline),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withAlpha(50),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (config.logoUrl.isNotEmpty)
                Image.network(config.logoUrl, height: 32, fit: BoxFit.contain)
              else
                Icon(Icons.fitness_center, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Text(
                config.gymName.isNotEmpty ? config.gymName : 'GymKit',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(Icons.person, size: 16, color: theme.colorScheme.onPrimaryContainer),
                    const SizedBox(width: 6),
                    Text(
                      role?.toUpperCase() ?? 'GUEST',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              IconButton.filled(
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                  foregroundColor: theme.colorScheme.onError,
                ),
                icon: const Icon(Icons.logout),
                tooltip: 'Log out',
                onPressed: () => ref.read(authRepositoryProvider).logout(),
              ),
            ],
          ),
        ],
      ),
    );

    // Build bottom dock
    final currentPath = GoRouterState.of(context).uri.path;
    final bottomDock = Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withAlpha(240),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: theme.colorScheme.outline),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withAlpha(50),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (role != 'member')
            _DockItem(
              icon: Icons.dashboard,
              label: 'Dashboard',
              isSelected: currentPath == '/dashboard',
              onTap: () => context.go('/dashboard'),
            ),
          if (role != 'member') ...[
            const SizedBox(width: 16),
            _DockItem(
              icon: Icons.people,
              label: 'Members',
              isSelected: currentPath == '/members',
              onTap: () => context.go('/members'),
            ),
          ],
          if (role == 'owner') ...[
            const SizedBox(width: 16),
            _DockItem(
              icon: Icons.settings,
              label: 'Settings',
              isSelected: currentPath == '/settings',
              onTap: () => context.go('/settings'),
            ),
          ],
          if (role == 'member') ...[
            _DockItem(
              icon: Icons.home,
              label: 'Home',
              isSelected: currentPath == '/member',
              onTap: () => context.go('/member'),
            ),
          ],
        ],
      ),
    );

    return Scaffold(
      body: Stack(
        children: [
          // Main content
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.only(top: 80, bottom: 80),
              child: child,
            ),
          ),
          // Top Dock
          Positioned(top: 0, left: 0, right: 0, child: SafeArea(child: topDock)),
          // Bottom Dock
          Positioned(bottom: 0, left: 0, right: 0, child: SafeArea(child: Center(child: bottomDock))),
        ],
      ),
    );
  }
}

class _DockItem extends StatelessWidget {
  const _DockItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurface,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
