import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/firestore_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../shared/models/app_user.dart';
import '../../../../shared/models/application.dart';
import '../../../../shared/widgets/app_primary_button.dart';
import '../../../application/presentation/controllers/application_controller.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../bookmark/presentation/controllers/bookmark_controller.dart';
import '../controllers/profile_controller.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _bioController;
  late final TextEditingController _skillsController;
  late final TextEditingController _githubController;
  late final TextEditingController _linkedinController;
  late final TextEditingController _websiteController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _bioController = TextEditingController();
    _skillsController = TextEditingController();
    _githubController = TextEditingController();
    _linkedinController = TextEditingController();
    _websiteController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _skillsController.dispose();
    _githubController.dispose();
    _linkedinController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  void _populateFields(AppUser? appUser) {
    if (appUser == null) return;
    if (_nameController.text.isEmpty) _nameController.text = appUser.name;
    if (_bioController.text.isEmpty) _bioController.text = appUser.bio ?? '';
    if (_skillsController.text.isEmpty) {
      _skillsController.text = appUser.skills.join(', ');
    }
    if (_githubController.text.isEmpty) {
      _githubController.text = appUser.githubUrl ?? '';
    }
    if (_linkedinController.text.isEmpty) {
      _linkedinController.text = appUser.linkedinUrl ?? '';
    }
    if (_websiteController.text.isEmpty) {
      _websiteController.text = appUser.websiteUrl ?? '';
    }
  }

  Future<void> _submit(BuildContext sheetContext) async {
    if (!_formKey.currentState!.validate()) return;
    final appUser = ref.read(currentAppUserProvider).value;
    if (appUser == null) return;

    final success = await ref
        .read(profileControllerProvider.notifier)
        .updateProfile(
          uid: appUser.uid,
          name: _nameController.text,
          bio: _bioController.text,
          skills: _skillsController.text
              .split(',')
              .map((skill) => skill.trim())
              .where((skill) => skill.isNotEmpty)
              .toList(),
          githubUrl: _githubController.text,
          linkedinUrl: _linkedinController.text,
          websiteUrl: _websiteController.text,
        );

    if (!sheetContext.mounted) return;
    if (success) {
      Navigator.of(sheetContext).pop();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully.')),
      );
    } else {
      ScaffoldMessenger.of(sheetContext).showSnackBar(
        SnackBar(
          content: Text(
            ref.read(profileControllerProvider).errorMessage ?? 'Failed',
          ),
        ),
      );
    }
  }

  void _openEditSheet(AppUser appUser) {
    _populateFields(appUser);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(sheetContext).size.height * 0.85,
            ),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Consumer(
              builder: (context, ref, _) {
                final profileState = ref.watch(profileControllerProvider);
                return SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Edit Profile',
                          style: AppTextStyles.heading2.copyWith(fontSize: 20),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(labelText: 'Name'),
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                              ? 'Required'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _bioController,
                          minLines: 3,
                          maxLines: 4,
                          decoration: const InputDecoration(labelText: 'Bio'),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _skillsController,
                          decoration: const InputDecoration(
                            labelText: 'Skills (comma separated)',
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _githubController,
                          decoration: const InputDecoration(
                            labelText: 'GitHub URL',
                          ),
                          keyboardType: TextInputType.url,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _linkedinController,
                          decoration: const InputDecoration(
                            labelText: 'LinkedIn URL',
                          ),
                          keyboardType: TextInputType.url,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _websiteController,
                          decoration: const InputDecoration(
                            labelText: 'Portfolio Website',
                          ),
                          keyboardType: TextInputType.url,
                        ),
                        const SizedBox(height: 18),
                        AppPrimaryButton(
                          label: 'Save Profile',
                          isLoading: profileState.isLoading,
                          onPressed: () => _submit(sheetContext),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appUser = ref.watch(currentAppUserProvider).value;

    if (appUser == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isStudent = appUser.role == UserRoles.student;

    final applications = isStudent
        ? ref.watch(studentApplicationsProvider(appUser.uid)).value ??
              const <ApplicationModel>[]
        : const <ApplicationModel>[];
    final savedCount = isStudent
        ? ref.watch(studentBookmarkMapProvider(appUser.uid)).value?.length ?? 0
        : 0;
    final acceptedCount = applications
        .where((app) => app.status.toLowerCase() == 'accepted')
        .length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, AppColors.secondary],
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(28),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white.withValues(alpha: 0.22),
                      child: Text(
                        appUser.name.isNotEmpty
                            ? appUser.name[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      appUser.name.isNotEmpty ? appUser.name : 'Your Profile',
                      style: AppTextStyles.heading1.copyWith(
                        fontSize: 22,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      appUser.email,
                      style: AppTextStyles.body.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (isStudent) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        _StatColumn(
                          value: applications.length,
                          label: 'Applications',
                        ),
                        _StatDivider(),
                        _StatColumn(value: savedCount, label: 'Saved'),
                        _StatDivider(),
                        _StatColumn(value: acceptedCount, label: 'Accepted'),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                _MenuTile(
                  icon: Icons.person_outline,
                  label: 'Edit Profile',
                  onTap: () => _openEditSheet(appUser),
                ),
                if (isStudent) ...[
                  _MenuTile(
                    icon: Icons.stars_outlined,
                    label: 'Skills & Interests',
                    onTap: () => _showSkillsSheet(context, appUser),
                  ),
                  _MenuTile(
                    icon: Icons.bookmark_border,
                    label: 'Saved Opportunities',
                    onTap: () => context.go(AppRoutes.studentBookmarks),
                  ),
                ],
                _MenuTile(
                  icon: Icons.dark_mode_outlined,
                  label: 'Appearance',
                  trailing: _themeModeLabel(ref.watch(themeModeProvider)),
                  onTap: () => _showAppearanceSheet(context, ref),
                ),
                _MenuTile(
                  icon: Icons.help_outline,
                  label: 'Help & Support',
                  onTap: () => showDialog<void>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Help & Support'),
                      content: const Text(
                        'Need help? Reach out to your ALU program team or the '
                        'Campus Ventures Link admin for support with your '
                        'account, applications, or startup listings.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  ),
                ),
                _MenuTile(
                  icon: Icons.logout_outlined,
                  label: 'Logout',
                  isDestructive: true,
                  onTap: () =>
                      ref.read(authControllerProvider.notifier).logout(),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _showSkillsSheet(BuildContext context, AppUser appUser) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Skills & Interests',
              style: AppTextStyles.heading2.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 14),
            appUser.skills.isEmpty
                ? Text(
                    'No skills added yet. Tap Edit Profile to add some.',
                    style: AppTextStyles.body,
                  )
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: appUser.skills
                        .map(
                          (skill) => Chip(
                            label: Text(skill),
                            backgroundColor: AppColors.primary.withValues(
                              alpha: 0.10,
                            ),
                          ),
                        )
                        .toList(),
                  ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  String _themeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  void _showAppearanceSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        return Consumer(
          builder: (context, ref, _) {
            final current = ref.watch(themeModeProvider);
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                      child: Text(
                        'Appearance',
                        style: AppTextStyles.heading2.copyWith(fontSize: 18),
                      ),
                    ),
                    for (final mode in ThemeMode.values)
                      ListTile(
                        leading: Icon(
                          current == mode
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                          color: current == mode
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                        title: Text(_themeModeLabel(mode)),
                        subtitle: mode == ThemeMode.system
                            ? const Text("Match this device's setting")
                            : null,
                        onTap: () {
                          ref
                              .read(themeModeProvider.notifier)
                              .setThemeMode(mode);
                          Navigator.of(sheetContext).pop();
                        },
                      ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _StatColumn extends StatelessWidget {
  final int value;
  final String label;

  const _StatColumn({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text('$value', style: AppTextStyles.heading1.copyWith(fontSize: 22)),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.body.copyWith(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      color: AppColors.textSecondary.withValues(alpha: 0.12),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;
  final String? trailing;

  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.error : AppColors.textPrimary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isDestructive ? AppColors.error : AppColors.primary,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: AppTextStyles.body.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (trailing != null) ...[
                  Text(
                    trailing!,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                if (!isDestructive)
                  Icon(Icons.chevron_right, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
