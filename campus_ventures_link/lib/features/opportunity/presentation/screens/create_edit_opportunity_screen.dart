import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_chip.dart';
import '../../../../shared/widgets/app_primary_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/gradient_header.dart';
import '../../../../shared/widgets/section_card.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../startup/presentation/controllers/startup_controller.dart';
import '../controllers/opportunity_controller.dart';

const _categoryOptions = [
  'Software Development',
  'Design',
  'Marketing',
  'Operations',
  'Research',
  'Business Analysis',
  'Content Creation',
  'Community Management',
  'Other',
];

const _employmentTypeOptions = [
  'Internship',
  'Part-time',
  'Full-time',
  'Contract',
  'Volunteer',
];

class CreateEditOpportunityScreen extends ConsumerStatefulWidget {
  const CreateEditOpportunityScreen({super.key});

  @override
  ConsumerState<CreateEditOpportunityScreen> createState() =>
      _CreateEditOpportunityScreenState();
}

class _CreateEditOpportunityScreenState
    extends ConsumerState<CreateEditOpportunityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _skillInputController = TextEditingController();
  final List<String> _skills = [];

  String? _selectedCategory;
  String? _selectedEmploymentType;
  DateTime? _deadline;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _skillInputController.dispose();
    super.dispose();
  }

  void _addSkill() {
    final skill = _skillInputController.text.trim();
    if (skill.isEmpty || _skills.contains(skill)) return;
    setState(() {
      _skills.add(skill);
      _skillInputController.clear();
    });
  }

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  void _closeScreen() {
    if (!mounted) return;
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      context.go(AppRoutes.founderOpportunities);
    }
  }

  Future<void> _submit(String startupId) async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a category')));
      return;
    }
    if (_selectedEmploymentType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an employment type')),
      );
      return;
    }
    if (_deadline == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a deadline')));
      return;
    }

    final success = await ref
        .read(opportunityControllerProvider.notifier)
        .createOpportunity(
          startupId: startupId,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          category: _selectedCategory!,
          location: _locationController.text.trim(),
          employmentType: _selectedEmploymentType!,
          requiredSkills: _skills,
          deadline: _deadline!,
        );

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Opportunity posted')));
      _closeScreen();
    } else {
      final err =
          ref.read(opportunityControllerProvider).errorMessage ??
          'Failed to post opportunity';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final appUser = ref.watch(currentAppUserProvider).value;

    if (appUser == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final startupAsync = ref.watch(startupByOwnerProvider(appUser.uid));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: startupAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Unable to load your startup: $error')),
        data: (startup) {
          if (startup == null) {
            return _BlockedState(
              icon: Icons.business_outlined,
              message:
                  'You need a startup profile before posting opportunities.',
              actionLabel: 'Create Startup',
              onAction: () => context.go(AppRoutes.founderStartup),
            );
          }

          final status = startup.verificationStatus.toLowerCase();
          final isApproved = status == 'approved' || status == 'active';

          if (!isApproved) {
            return _BlockedState(
              icon: Icons.hourglass_top_outlined,
              message: status == 'rejected'
                  ? '${startup.startupName} was rejected by ALU admin.'
                        ' Update your profile and resubmit for review.'
                  : '${startup.startupName} is awaiting ALU admin'
                        ' verification. You can post opportunities once'
                        ' approved.',
              statusBadge: StatusBadge(status: startup.verificationStatus),
              actionLabel: 'View my startup',
              onAction: () => context.go(AppRoutes.founderStartup),
            );
          }

          return _OpportunityForm(
            formKey: _formKey,
            titleController: _titleController,
            descriptionController: _descriptionController,
            locationController: _locationController,
            skillInputController: _skillInputController,
            skills: _skills,
            onAddSkill: _addSkill,
            onRemoveSkill: (skill) => setState(() => _skills.remove(skill)),
            selectedCategory: _selectedCategory,
            onCategoryChanged: (value) =>
                setState(() => _selectedCategory = value),
            selectedEmploymentType: _selectedEmploymentType,
            onEmploymentTypeChanged: (value) =>
                setState(() => _selectedEmploymentType = value),
            deadline: _deadline,
            startupName: startup.startupName,
            onPickDeadline: _pickDeadline,
            onSubmit: () => _submit(startup.id),
            onCancel: _closeScreen,
          );
        },
      ),
    );
  }
}

class _BlockedState extends StatelessWidget {
  final IconData icon;
  final String message;
  final Widget? statusBadge;
  final String actionLabel;
  final VoidCallback onAction;

  const _BlockedState({
    required this.icon,
    required this.message,
    required this.actionLabel,
    required this.onAction,
    this.statusBadge,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(icon, size: 30, color: AppColors.primary),
              ),
              const SizedBox(height: 18),
              if (statusBadge != null) ...[
                statusBadge!,
                const SizedBox(height: 10),
              ],
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTextStyles.body,
              ),
              const SizedBox(height: 20),
              AppPrimaryButton(label: actionLabel, onPressed: onAction),
            ],
          ),
        ),
      ),
    );
  }
}

class _OpportunityForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController locationController;
  final TextEditingController skillInputController;
  final List<String> skills;
  final VoidCallback onAddSkill;
  final ValueChanged<String> onRemoveSkill;
  final String? selectedCategory;
  final ValueChanged<String?> onCategoryChanged;
  final String? selectedEmploymentType;
  final ValueChanged<String?> onEmploymentTypeChanged;
  final DateTime? deadline;
  final String startupName;
  final VoidCallback onPickDeadline;
  final VoidCallback onSubmit;
  final VoidCallback onCancel;

  const _OpportunityForm({
    required this.formKey,
    required this.titleController,
    required this.descriptionController,
    required this.locationController,
    required this.skillInputController,
    required this.skills,
    required this.onAddSkill,
    required this.onRemoveSkill,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.selectedEmploymentType,
    required this.onEmploymentTypeChanged,
    required this.deadline,
    required this.startupName,
    required this.onPickDeadline,
    required this.onSubmit,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final state = ref.watch(opportunityControllerProvider);

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: GradientHeader(
                title: '\u{1F4E2} Create Opportunity',
                subtitle: 'Post an internship for ALU students',
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              sliver: SliverToBoxAdapter(
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.business_outlined,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Posting as $startupName',
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      SectionCard(
                        title: 'Basic Information',
                        icon: Icons.description_outlined,
                        child: Column(
                          children: [
                            AppTextField(
                              controller: titleController,
                              label: 'Title',
                              hint: 'e.g. Flutter Developer Intern',
                              validator: (v) => v == null || v.trim().isEmpty
                                  ? 'Enter a title'
                                  : null,
                            ),
                            const SizedBox(height: 14),
                            AppTextField(
                              controller: descriptionController,
                              label: 'Description',
                              hint: 'What will the intern work on?',
                              maxLines: 4,
                              validator: (v) => v == null || v.trim().isEmpty
                                  ? 'Enter a description'
                                  : null,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      SectionCard(
                        title: 'Opportunity Details',
                        icon: Icons.tune_outlined,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Category',
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              key: const Key('category_dropdown'),
                              initialValue: selectedCategory,
                              isExpanded: true,
                              hint: const Text('Select a category'),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: AppColors.background,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                              ),
                              items: _categoryOptions
                                  .map(
                                    (c) => DropdownMenuItem(
                                      value: c,
                                      child: Text(c),
                                    ),
                                  )
                                  .toList(),
                              onChanged: onCategoryChanged,
                              validator: (value) =>
                                  value == null ? 'Select a category' : null,
                            ),
                            const SizedBox(height: 16),
                            AppTextField(
                              controller: locationController,
                              label: 'Location',
                              hint: 'e.g. Kigali, Remote',
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Employment type',
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _employmentTypeOptions
                                  .map(
                                    (type) => AppChip(
                                      label: type,
                                      selected: selectedEmploymentType == type,
                                      onTap: () =>
                                          onEmploymentTypeChanged(type),
                                    ),
                                  )
                                  .toList(),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Deadline',
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            OutlinedButton.icon(
                              onPressed: onPickDeadline,
                              icon: const Icon(Icons.event_outlined, size: 18),
                              label: Text(
                                deadline == null
                                    ? 'Select date'
                                    : '${deadline!.year}-${deadline!.month.toString().padLeft(2, '0')}-${deadline!.day.toString().padLeft(2, '0')}',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      SectionCard(
                        title: 'Required Skills',
                        icon: Icons.stars_outlined,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: skillInputController,
                                    decoration: const InputDecoration(
                                      hintText: 'e.g. Flutter, Figma',
                                    ),
                                    onFieldSubmitted: (_) => onAddSkill(),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton.filled(
                                  onPressed: onAddSkill,
                                  icon: const Icon(Icons.add),
                                ),
                              ],
                            ),
                            if (skills.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: skills
                                    .map(
                                      (skill) => AppChip(
                                        label: skill,
                                        selected: true,
                                        onDeleted: () => onRemoveSkill(skill),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: state.isLoading ? null : onCancel,
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: AppPrimaryButton(
                              label: 'Publish Opportunity',
                              isLoading: state.isLoading,
                              onPressed: onSubmit,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
