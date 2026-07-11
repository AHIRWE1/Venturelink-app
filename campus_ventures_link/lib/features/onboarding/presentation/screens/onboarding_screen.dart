import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/firestore_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_primary_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _githubController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _websiteController = TextEditingController();
  final _skillInputController = TextEditingController();

  String _selectedRole = UserRoles.student;
  final List<String> _skills = [];

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _githubController.dispose();
    _linkedinController.dispose();
    _websiteController.dispose();
    _skillInputController.dispose();
    super.dispose();
  }

  void _addSkill() {
    final skill = _skillInputController.text.trim();
    if (skill.isEmpty || _skills.contains(skill)) {
      return;
    }
    setState(() {
      _skills.add(skill);
      _skillInputController.clear();
    });
  }

  void _removeSkill(String skill) {
    setState(() => _skills.remove(skill));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_skills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add at least one skill'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final firebaseUser = ref.read(authStateChangesProvider).value;
    if (firebaseUser == null) {
      return;
    }

    final success =
        await ref.read(onboardingControllerProvider.notifier).submit(
              uid: firebaseUser.uid,
              name: _nameController.text,
              role: _selectedRole,
              skills: _skills,
              bio: _bioController.text,
              githubUrl: _githubController.text,
              linkedinUrl: _linkedinController.text,
              websiteUrl: _websiteController.text,
            );

    if (success && mounted) {
      // Router redirect sends user to the correct dashboard.
    }
  }

  @override
  Widget build(BuildContext context) {
    final onboardingState = ref.watch(onboardingControllerProvider);

    ref.listen(onboardingControllerProvider, (previous, next) {
      if (next.errorMessage != null && next.errorMessage!.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.06),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person_pin_circle_outlined,
                          color: AppColors.primary,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Tell us about yourself',
                  style: AppTextStyles.heading1.copyWith(fontSize: 26),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'This helps startups find the right talent and helps students discover relevant opportunities.',
                  style: AppTextStyles.body,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                AppTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  hint: 'Enter your full name',
                  validator: (value) =>
                      Validators.requiredField(value, 'Full name'),
                ),
                const SizedBox(height: 20),
                Text(
                  'I am a',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: UserRoles.student,
                      label: Text('Student'),
                      icon: Icon(Icons.school_outlined),
                    ),
                    ButtonSegment(
                      value: UserRoles.founder,
                      label: Text('Founder'),
                      icon: Icon(Icons.lightbulb_outline),
                    ),
                  ],
                  selected: {_selectedRole},
                  onSelectionChanged: (selection) {
                    setState(() => _selectedRole = selection.first);
                  },
                ),
                const SizedBox(height: 20),
                Text(
                  'Skills',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _skillInputController,
                        decoration: const InputDecoration(
                          hintText: 'e.g. Flutter, UI Design',
                        ),
                        onFieldSubmitted: (_) => _addSkill(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed: _addSkill,
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  alignment: Alignment.topLeft,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _skills
                        .map(
                          (skill) => TweenAnimationBuilder<double>(
                            key: ValueKey(skill),
                            tween: Tween(begin: 0, end: 1),
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOutBack,
                            builder: (context, value, child) =>
                                Transform.scale(scale: value, child: child),
                            child: Chip(
                              label: Text(skill),
                              backgroundColor: AppColors.primary.withValues(
                                alpha: 0.10,
                              ),
                              labelStyle: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                              deleteIcon: const Icon(
                                Icons.close,
                                size: 18,
                                color: AppColors.primary,
                              ),
                              onDeleted: () => _removeSkill(skill),
                              side: BorderSide.none,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                const SizedBox(height: 20),
                AppTextField(
                  controller: _bioController,
                  label: 'Bio',
                  hint: 'Briefly describe your background and interests',
                  maxLines: 4,
                  validator: (value) =>
                      Validators.requiredField(value, 'Bio'),
                ),
                const SizedBox(height: 20),
                AppTextField(
                  controller: _githubController,
                  label: 'GitHub URL (optional)',
                  hint: 'https://github.com/username',
                  keyboardType: TextInputType.url,
                  validator: Validators.optionalUrl,
                ),
                const SizedBox(height: 20),
                AppTextField(
                  controller: _linkedinController,
                  label: 'LinkedIn URL (optional)',
                  hint: 'https://linkedin.com/in/username',
                  keyboardType: TextInputType.url,
                  validator: Validators.optionalUrl,
                ),
                const SizedBox(height: 20),
                AppTextField(
                  controller: _websiteController,
                  label: 'Portfolio / Website (optional)',
                  hint: 'https://yourportfolio.com',
                  keyboardType: TextInputType.url,
                  validator: Validators.optionalUrl,
                ),
                const SizedBox(height: 32),
                AppPrimaryButton(
                  label: 'Continue to Dashboard',
                  isLoading: onboardingState.isLoading,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
