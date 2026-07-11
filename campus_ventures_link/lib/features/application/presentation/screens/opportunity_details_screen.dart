import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/models/opportunity.dart';
import '../../../../shared/widgets/app_primary_button.dart';
import '../../../../shared/widgets/bookmark_toggle_button.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../startup/presentation/controllers/startup_controller.dart';
import '../controllers/application_controller.dart';

class OpportunityDetailsScreen extends ConsumerStatefulWidget {
  final Opportunity opportunity;

  const OpportunityDetailsScreen({super.key, required this.opportunity});

  @override
  ConsumerState<OpportunityDetailsScreen> createState() =>
      _OpportunityDetailsScreenState();
}

class _OpportunityDetailsScreenState
    extends ConsumerState<OpportunityDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _coverLetterController = TextEditingController();

  @override
  void dispose() {
    _coverLetterController.dispose();
    super.dispose();
  }

  Future<void> _apply(BuildContext sheetContext, String uid) async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref
        .read(applicationControllerProvider.notifier)
        .apply(
          studentId: uid,
          startupId: widget.opportunity.startupId,
          opportunityId: widget.opportunity.id,
          coverLetter: _coverLetterController.text,
        );

    if (!sheetContext.mounted) return;
    if (success) {
      Navigator.of(sheetContext).pop();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Application submitted successfully.')),
      );
    } else {
      ScaffoldMessenger.of(sheetContext).showSnackBar(
        SnackBar(
          content: Text(
            ref.read(applicationControllerProvider).errorMessage ?? 'Failed',
          ),
        ),
      );
    }
  }

  void _openApplySheet(String uid) {
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
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Consumer(
              builder: (context, ref, _) {
                final applicationState = ref.watch(
                  applicationControllerProvider,
                );
                return Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.textSecondary.withValues(
                              alpha: 0.3,
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Why are you a fit?',
                        style: AppTextStyles.heading2.copyWith(fontSize: 18),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Share your motivation and relevant experience for'
                        ' ${widget.opportunity.title}.',
                        style: AppTextStyles.body,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _coverLetterController,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          hintText:
                              'Share your motivation and relevant experience...',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Please add a message.'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      AppPrimaryButton(
                        label: 'Submit Application',
                        isLoading: applicationState.isLoading,
                        onPressed: () => _apply(sheetContext, uid),
                      ),
                    ],
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

    final startupAsync = ref.watch(
      startupByIdProvider(widget.opportunity.startupId),
    );
    final applicationsAsync = ref.watch(
      studentApplicationsProvider(appUser.uid),
    );
    final existingApplication = applicationsAsync.value?.where(
      (app) => app.opportunityId == widget.opportunity.id,
    ).firstOrNull;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Opportunity Details'),
        actions: [
          BookmarkToggleButton(
            studentId: appUser.uid,
            opportunityId: widget.opportunity.id,
          ),
          IconButton(
            tooltip: 'Share',
            icon: const Icon(Icons.ios_share_outlined),
            onPressed: () async {
              final startupName = startupAsync.value?.startupName ?? 'ALU';
              await Clipboard.setData(
                ClipboardData(
                  text:
                      '${widget.opportunity.title} at $startupName — '
                      'shared from Campus Ventures Link.',
                ),
              );
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Details copied to clipboard.')),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.work_outline,
                      color: AppColors.primary,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.opportunity.title,
                          style: AppTextStyles.heading1.copyWith(
                            fontSize: 22,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          startupAsync.value?.startupName ?? 'ALU Startup',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _Tag(label: widget.opportunity.category),
                  _Tag(label: widget.opportunity.employmentType),
                  _Tag(label: widget.opportunity.location),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
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
                child: Column(
                  children: [
                    _InfoRow(
                      icon: Icons.schedule_outlined,
                      label: widget.opportunity.employmentType,
                    ),
                    const Divider(height: 20),
                    _InfoRow(
                      icon: Icons.location_on_outlined,
                      label: widget.opportunity.location,
                    ),
                    if (widget.opportunity.createdAt != null) ...[
                      const Divider(height: 20),
                      _InfoRow(
                        icon: Icons.event_outlined,
                        label:
                            'Posted ${_fmtDate(widget.opportunity.createdAt!)}',
                      ),
                    ],
                    if (widget.opportunity.deadline != null) ...[
                      const Divider(height: 20),
                      _InfoRow(
                        icon: Icons.flag_outlined,
                        label:
                            'Deadline ${_fmtDate(widget.opportunity.deadline!)}',
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text('About', style: AppTextStyles.heading2.copyWith(fontSize: 18)),
              const SizedBox(height: 8),
              Text(
                widget.opportunity.description.isNotEmpty
                    ? widget.opportunity.description
                    : 'No description provided yet.',
                style: AppTextStyles.body,
              ),
              const SizedBox(height: 24),
              Text(
                'Skills required',
                style: AppTextStyles.heading2.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 10),
              widget.opportunity.requiredSkills.isEmpty
                  ? Text('No specific skills listed.', style: AppTextStyles.body)
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.opportunity.requiredSkills
                          .map((skill) => _Tag(label: skill))
                          .toList(),
                    ),
              const SizedBox(height: 28),
              if (existingApplication != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'You already applied to this opportunity.',
                          style: AppTextStyles.body,
                        ),
                      ),
                      StatusBadge(status: existingApplication.status),
                    ],
                  ),
                )
              else
                AppPrimaryButton(
                  label: 'Apply Now',
                  onPressed: () => _openApplySheet(appUser.uid),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _fmtDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(child: Text(label, style: AppTextStyles.body)),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;

  const _Tag({required this.label});

  @override
  Widget build(BuildContext context) {
    if (label.trim().isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: AppTextStyles.body.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }
}
