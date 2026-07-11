import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/firestore_constants.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

class MainShell extends ConsumerStatefulWidget {
  final Widget child;
  final StatefulNavigationShell navigationShell;

  const MainShell({
    super.key,
    required this.child,
    required this.navigationShell,
  });

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  @override
  Widget build(BuildContext context) {
    final appUser = ref.watch(currentAppUserProvider).value;
    if (appUser == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final items = _navigationItemsForRole(appUser.role);

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: widget.navigationShell.currentIndex,
        onDestinationSelected: (index) =>
            widget.navigationShell.goBranch(index),
        indicatorColor: AppColors.primary.withValues(alpha: 0.16),
        destinations: items
            .map(
              (item) => NavigationDestination(
                icon: Icon(item.icon),
                label: item.label,
              ),
            )
            .toList(),
      ),
    );
  }

  List<_NavItem> _navigationItemsForRole(String role) {
    switch (role) {
      case UserRoles.admin:
        return const [
          _NavItem(label: 'Dashboard', icon: Icons.dashboard_outlined),
          _NavItem(label: 'Verify', icon: Icons.verified_outlined),
          _NavItem(label: 'Users', icon: Icons.people_outline),
          _NavItem(label: 'Profile', icon: Icons.person_outline),
        ];
      case UserRoles.founder:
        return const [
          _NavItem(label: 'Dashboard', icon: Icons.dashboard_outlined),
          _NavItem(label: 'Startup', icon: Icons.business_outlined),
          _NavItem(label: 'Opportunities', icon: Icons.work_outline),
          _NavItem(label: 'Applicants', icon: Icons.people_outline),
          _NavItem(label: 'Profile', icon: Icons.person_outline),
        ];
      case UserRoles.student:
      default:
        return const [
          _NavItem(label: 'Home', icon: Icons.home_outlined),
          _NavItem(label: 'Explore', icon: Icons.explore_outlined),
          _NavItem(label: 'Applications', icon: Icons.assignment_outlined),
          _NavItem(label: 'Bookmarks', icon: Icons.bookmark_outline),
          _NavItem(label: 'Profile', icon: Icons.person_outline),
        ];
    }
  }
}

class _NavItem {
  final String label;
  final IconData icon;

  const _NavItem({required this.label, required this.icon});
}
