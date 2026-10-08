import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/attendance/presentation/global_scanner_listener.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_sidebar.dart';
import '../config/tenant_config.dart';
import '../config/tenant_config_repository.dart';

class AppLayout extends ConsumerWidget {
  const AppLayout({super.key, required this.child});
  final Widget child;

  String _getTitleFromPath(String path) {
    if (path == '/dashboard') return 'Dashboard';
    if (path.startsWith('/members')) return 'Members';
    if (path.startsWith('/trainers')) return 'Trainers';
    if (path.startsWith('/plans')) return 'Memberships';
    if (path.startsWith('/attendance') || path.startsWith('/kiosk')) return 'Attendance';
    if (path.startsWith('/payments')) return 'Payments';
    if (path.startsWith('/workouts')) return 'Workout & Progress';
    if (path.startsWith('/reports')) return 'Reports';
    if (path.startsWith('/settings')) return 'Settings';
    if (path.startsWith('/classes')) return 'Classes';
    if (path == '/member') return 'Home';
    return 'Dashboard';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(authRepositoryProvider).currentRole;
    final configAsync = ref.watch(tenantConfigProvider);
    final config = configAsync.value ?? const TenantConfig();
    final currentPath = GoRouterState.of(context).uri.path;
    
    // For normal members, we can still use a simplified mobile bottom nav layout,
    // but the prompt focused on Admin Dashboard. 
    // We will render the full Admin Dashboard layout for admins.
    final isMobileView = MediaQuery.sizeOf(context).width < 1024;
    final isMember = role == 'member';

    if (isMember) {
      return Scaffold(
        body: child,
        bottomNavigationBar: NavigationBar(
          selectedIndex: 0,
          onDestinationSelected: (idx) {},
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
            NavigationDestination(icon: Icon(Icons.fitness_center), label: 'Workout'),
            NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      );
    }

    final mainContent = Column(
      children: [
        AppHeader(title: _getTitleFromPath(currentPath)),
        Expanded(
          child: GlobalScannerListener(
            child: child,
          ),
        ),
      ],
    );

    return Scaffold(
      drawer: isMobileView
          ? Drawer(
              child: AppSidebar(
                currentPath: currentPath,
                gymName: config.gymName,
                logoUrl: config.logoUrl,
                onNavigate: (path) {
                  Navigator.of(context).pop(); // Close drawer
                  context.go(path);
                },
              ),
            )
          : null,
      body: Row(
        children: [
          if (!isMobileView)
            AppSidebar(
              currentPath: currentPath,
              gymName: config.gymName,
              logoUrl: config.logoUrl,
              onNavigate: (path) => context.go(path),
            ),
          Expanded(
            child: mainContent,
          ),
        ],
      ),
    );
  }
}
