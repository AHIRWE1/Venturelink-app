import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/firestore_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/models/app_user.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/admin_user_controller.dart';

const _roleFilters = ['All', UserRoles.student, UserRoles.founder, UserRoles.admin];
const _assignableRoles = [UserRoles.student, UserRoles.founder, UserRoles.admin];

class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen> {
  String _selectedRole = 'All';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(allUsersProvider);
    final currentUid = ref.watch(currentAppUserProvider).value?.uid;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Users')),
      body: usersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Unable to load users: $error')),
        data: (users) {
          final query = _searchController.text.trim().toLowerCase();
          final filtered = users.where((u) {
            if (_selectedRole != 'All' && u.role != _selectedRole) {
              return false;
            }
            if (query.isEmpty) return true;
            return u.name.toLowerCase().contains(query) ||
                u.email.toLowerCase().contains(query);
          }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search_outlined),
                    hintText: 'Search by name or email…',
                    filled: true,
                    fillColor: AppColors.secondary.withValues(alpha: 0.06),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 46,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: _roleFilters.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final role = _roleFilters[index];
                    final isSelected = role == _selectedRole;
                    final label = role == 'All'
                        ? 'All'
                        : role[0].toUpperCase() + role.substring(1);
                    return ChoiceChip(
                      label: Text(label),
                      selected: isSelected,
                      onSelected: (_) => setState(() => _selectedRole = role),
                      selectedColor: AppColors.primary.withValues(alpha: 0.18),
                      backgroundColor: AppColors.secondary.withValues(
                        alpha: 0.08,
                      ),
                      labelStyle: AppTextStyles.body.copyWith(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.normal,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: filtered.isEmpty
                    ? const EmptyStateWidget(
                        icon: Icons.people_outline,
                        title: 'No users match this filter',
                        subtitle: 'Try a different role filter or search term.',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) => _UserCard(
                          user: filtered[index],
                          isCurrentUser: filtered[index].uid == currentUid,
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _UserCard extends ConsumerWidget {
  final AppUser user;
  final bool isCurrentUser;

  const _UserCard({required this.user, required this.isCurrentUser});

  Color _roleColorFor(String role) {
    switch (role) {
      case UserRoles.founder:
        return AppColors.secondary;
      case UserRoles.admin:
        return AppColors.warning;
      case UserRoles.student:
      default:
        return AppColors.primary;
    }
  }

  Future<void> _changeRole(
    BuildContext context,
    WidgetRef ref,
    String newRole,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change role?'),
        content: Text(
          'Set ${user.name.isNotEmpty ? user.name : user.email}\'s role to'
          ' "${newRole[0].toUpperCase()}${newRole.substring(1)}"? This'
          ' changes what they can see and do in the app immediately.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final success = await ref
        .read(adminUserControllerProvider.notifier)
        .updateRole(uid: user.uid, role: newRole);

    if (!context.mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Role updated to ${newRole[0].toUpperCase()}${newRole.substring(1)}.',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to update role.')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roleColor = _roleColorFor(user.role);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: roleColor.withValues(alpha: 0.14),
            child: Text(
              user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
              style: TextStyle(color: roleColor, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name.isNotEmpty ? user.name : 'Unnamed user',
                  style: AppTextStyles.heading2.copyWith(fontSize: 15),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  user.email,
                  style: AppTextStyles.body.copyWith(fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (isCurrentUser)
            Tooltip(
              message: "You can't change your own role.",
              child: _RolePill(role: user.role, color: roleColor),
            )
          else
            PopupMenuButton<String>(
              tooltip: 'Change role',
              onSelected: (role) => _changeRole(context, ref, role),
              itemBuilder: (context) => _assignableRoles
                  .map(
                    (role) => PopupMenuItem(
                      value: role,
                      enabled: role != user.role,
                      child: Text(
                        '${role[0].toUpperCase()}${role.substring(1)}',
                      ),
                    ),
                  )
                  .toList(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _RolePill(role: user.role, color: roleColor),
                  Icon(
                    Icons.arrow_drop_down,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _RolePill extends StatelessWidget {
  final String role;
  final Color color;

  const _RolePill({required this.role, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        role.isEmpty ? 'unset' : role[0].toUpperCase() + role.substring(1),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}
