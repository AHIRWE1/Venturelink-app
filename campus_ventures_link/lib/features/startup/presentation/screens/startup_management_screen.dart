import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/models/startup.dart';
import '../../../../shared/widgets/app_primary_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/gradient_header.dart';
import '../../../../shared/widgets/section_card.dart';

import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/startup_controller.dart';
import '_startup_widgets.dart';

class StartupManagementScreen extends ConsumerStatefulWidget {
  const StartupManagementScreen({super.key});

  @override
  ConsumerState<StartupManagementScreen> createState() =>
      _StartupManagementScreenState();
}

class _StartupManagementScreenState
    extends ConsumerState<StartupManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _industryController = TextEditingController();
  final _teamSizeController = TextEditingController(text: '5');
  final _websiteController = TextEditingController();

  // Tracks which startup's data is currently loaded into the controllers so
  // we only populate them once per startup, and don't clobber in-progress
  // edits on every rebuild (Firestore stream re-emits on every keystroke's
  // rebuild otherwise).
  String? _populatedStartupId;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _industryController.dispose();
    _teamSizeController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  void _populateFrom(Startup startup) {
    if (_populatedStartupId == startup.id) return;
    _nameController.text = startup.startupName;
    _descriptionController.text = startup.description;
    _industryController.text = startup.industry;
    _teamSizeController.text = startup.teamSize > 0
        ? '${startup.teamSize}'
        : '5';
    _websiteController.text = startup.website;
    _populatedStartupId = startup.id;
  }

  Future<void> _create() async {
    if (!_formKey.currentState!.validate()) return;
    final user = ref.read(currentAppUserProvider).value;
    if (user == null) return;

    final success = await ref
        .read(startupControllerProvider.notifier)
        .createStartup(
          ownerId: user.uid,
          startupName: _nameController.text,
          description: _descriptionController.text,
          industry: _industryController.text,
          teamSize: int.tryParse(_teamSizeController.text) ?? 5,
          website: _websiteController.text,
        );

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Startup submitted for verification.')),
      );
      _nameController.clear();
      _descriptionController.clear();
      _industryController.clear();
      _teamSizeController.text = '5';
      _websiteController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ref.read(startupControllerProvider).errorMessage ?? 'Failed',
          ),
        ),
      );
    }
  }

  Future<void> _saveEdits(Startup startup) async {
    if (!_formKey.currentState!.validate()) return;

    final isRejected = startup.verificationStatus.toLowerCase() == 'rejected';
    // Resubmitting a rejected startup puts it back in the admin review
    // queue; editing an already pending/approved startup just saves the
    // details without touching its current verification status.
    final nextStatus = isRejected ? 'pending' : startup.verificationStatus;

    final success = await ref
        .read(startupControllerProvider.notifier)
        .updateStartup(
          id: startup.id,
          startupName: _nameController.text,
          description: _descriptionController.text,
          industry: _industryController.text,
          teamSize: int.tryParse(_teamSizeController.text) ?? 5,
          website: _websiteController.text,
          verificationStatus: nextStatus,
        );

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isRejected
                ? 'Startup resubmitted for review.'
                : 'Startup details updated.',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ref.read(startupControllerProvider).errorMessage ?? 'Failed',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentAppUserProvider).value;
    final startupState = ref.watch(startupControllerProvider);
    final startupList = ref.watch(startupListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () async {},
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(
              child: GradientHeader(
                title: 'My Startup',
                subtitle:
                    'Create and manage your verified startup presence for'
                    ' ALU opportunities.',
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (startupState.isLoading) ...[
                      const LinearProgressIndicator(),
                      const SizedBox(height: 16),
                    ],
                    startupList.when(
                      data: (startups) {
                        final myStartup = startups.isEmpty
                            ? null
                            : startups.first;

                        if (myStartup != null) {
                          _populateFrom(myStartup);
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (myStartup == null)
                              const EmptyStartupCard()
                            else ...[
                              StartupProfileCard(
                                startup: myStartup,
                                isOwner:
                                    user != null &&
                                    myStartup.ownerId == user.uid,
                              ),
                              if (myStartup.verificationStatus.toLowerCase() ==
                                  'rejected') ...[
                                const SizedBox(height: 16),
                                _RejectionBanner(),
                              ],
                            ],
                            const SizedBox(height: 20),
                            SectionCard(
                              title: myStartup == null
                                  ? 'Create your startup'
                                  : 'Edit startup details',
                              icon: Icons.business_outlined,
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    AppTextField(
                                      controller: _nameController,
                                      label: 'Startup Name',
                                      validator: (value) =>
                                          value == null || value.trim().isEmpty
                                          ? 'Required'
                                          : null,
                                    ),
                                    const SizedBox(height: 14),
                                    AppTextField(
                                      controller: _descriptionController,
                                      label: 'Description',
                                      maxLines: 3,
                                      validator: (value) =>
                                          value == null || value.trim().isEmpty
                                          ? 'Required'
                                          : null,
                                    ),
                                    const SizedBox(height: 14),
                                    AppTextField(
                                      controller: _industryController,
                                      label: 'Industry',
                                      validator: (value) =>
                                          value == null || value.trim().isEmpty
                                          ? 'Required'
                                          : null,
                                    ),
                                    const SizedBox(height: 14),
                                    AppTextField(
                                      controller: _teamSizeController,
                                      label: 'Team Size',
                                      keyboardType: TextInputType.number,
                                      validator: (value) =>
                                          value == null || value.trim().isEmpty
                                          ? 'Required'
                                          : null,
                                    ),
                                    const SizedBox(height: 14),
                                    AppTextField(
                                      controller: _websiteController,
                                      label: 'Website',
                                    ),
                                    const SizedBox(height: 18),
                                    AppPrimaryButton(
                                      isLoading: startupState.isLoading,
                                      label: myStartup == null
                                          ? 'Create Startup'
                                          : (myStartup.verificationStatus
                                                        .toLowerCase() ==
                                                    'rejected'
                                                ? 'Resubmit for Review'
                                                : 'Save Changes'),
                                      onPressed: myStartup == null
                                          ? _create
                                          : () => _saveEdits(myStartup),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                      loading: () => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (error, _) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          'Unable to load your startup: $error',
                          style: AppTextStyles.body,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RejectionBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: AppColors.error),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Your startup was rejected by ALU admin. Update the details '
              'below and tap "Resubmit for Review" to send it back for '
              'another look.',
              style: AppTextStyles.body,
            ),
          ),
        ],
      ),
    );
  }
}
