import 'package:flutter/material.dart';

class AppSidebar extends StatelessWidget {
  final String currentPath;
  final Function(String) onNavigate;
  final String gymName;
  final String logoUrl;

  const AppSidebar({
    super.key,
    required this.currentPath,
    required this.onNavigate,
    required this.gymName,
    this.logoUrl = '',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          right: BorderSide(color: theme.dividerColor.withOpacity(0.1)),
        ),
      ),
      child: Column(
        children: [
          _buildLogo(theme),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                _SidebarItem(
                  icon: Icons.dashboard_outlined,
                  activeIcon: Icons.dashboard,
                  label: 'Dashboard',
                  isSelected: currentPath == '/dashboard',
                  onTap: () => onNavigate('/dashboard'),
                ),
                _SidebarItem(
                  icon: Icons.people_outline,
                  activeIcon: Icons.people,
                  label: 'Members',
                  isSelected: currentPath.startsWith('/members'),
                  onTap: () => onNavigate('/members'),
                ),
                _SidebarItem(
                  icon: Icons.badge_outlined,
                  activeIcon: Icons.badge,
                  label: 'Trainers',
                  isSelected: currentPath.startsWith('/trainers'),
                  onTap: () => onNavigate('/trainers'),
                ),
                _SidebarItem(
                  icon: Icons.card_membership_outlined,
                  activeIcon: Icons.card_membership,
                  label: 'Memberships',
                  isSelected: currentPath.startsWith('/plans'),
                  onTap: () => onNavigate('/plans'),
                ),
                _SidebarItem(
                  icon: Icons.how_to_reg_outlined,
                  activeIcon: Icons.how_to_reg,
                  label: 'Attendance',
                  isSelected: currentPath.startsWith('/attendance'),
                  onTap: () => onNavigate('/attendance'),
                ),
                _SidebarItem(
                  icon: Icons.payments_outlined,
                  activeIcon: Icons.payments,
                  label: 'Payments',
                  isSelected: currentPath.startsWith('/payments'),
                  onTap: () => onNavigate('/payments'),
                ),
                _SidebarItem(
                  icon: Icons.fitness_center_outlined,
                  activeIcon: Icons.fitness_center,
                  label: 'Workout & Progress',
                  isSelected: currentPath.startsWith('/workouts'),
                  onTap: () => onNavigate('/workouts'),
                ),
                _SidebarItem(
                  icon: Icons.bar_chart_outlined,
                  activeIcon: Icons.bar_chart,
                  label: 'Reports',
                  isSelected: currentPath.startsWith('/reports'),
                  onTap: () => onNavigate('/reports'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _SidebarItem(
              icon: Icons.settings_outlined,
              activeIcon: Icons.settings,
              label: 'Settings',
              isSelected: currentPath.startsWith('/settings'),
              onTap: () => onNavigate('/settings'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          if (logoUrl.isNotEmpty)
            Image.network(logoUrl, height: 32, fit: BoxFit.contain)
          else
            Icon(Icons.fitness_center, color: theme.colorScheme.primary, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              gymName.isNotEmpty ? gymName : 'GymKit',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final onSurface = theme.colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? primary.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                isSelected ? activeIcon : icon,
                color: isSelected ? primary : onSurface.withOpacity(0.6),
                size: 22,
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isSelected ? primary : onSurface.withOpacity(0.8),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
