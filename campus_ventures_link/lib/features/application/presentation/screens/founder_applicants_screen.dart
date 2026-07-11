import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/application.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../startup/presentation/controllers/startup_controller.dart';

import '../controllers/application_controller.dart';

class FounderApplicantsScreen extends ConsumerWidget {
  const FounderApplicantsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentAppUserProvider).value;
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final startupAsync = ref.watch(startupByOwnerProvider(user.uid));

    return Scaffold(
      appBar: AppBar(title: const Text('Applicants')),
      body: startupAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Unable to load your startup: $error')),
        data: (startup) {
          if (startup == null) {
            return EmptyStateWidget(
              icon: Icons.business_outlined,
              title: 'No startup profile yet',
              subtitle: 'Create your startup profile first to receive'
                  ' applicants.',
              buttonText: 'Create Startup',
              onPressed: () => context.go(AppRoutes.founderStartup),
            );
          }
          return _ApplicantsList(startupId: startup.id);
        },
      ),
    );
  }
}

class _ApplicantsList extends ConsumerWidget {
  final String startupId;
  const _ApplicantsList({required this.startupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applications = ref.watch(startupApplicationsProvider(startupId));

    return applications.when(
      data: (items) {
        if (items.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.inbox_outlined,
            title: 'No applications received yet',
            subtitle: 'Applications from students will appear here.',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return _ApplicantCard(application: item);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) =>
          Center(child: Text('Unable to load applicants: $error')),
    );
  }
}

class _ApplicantCard extends ConsumerWidget {
  final ApplicationModel application;
  const _ApplicantCard({required this.application});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.secondary.withValues(alpha: 0.12),
          child: const Icon(Icons.person_outline, color: AppColors.secondary),
        ),
        title: Text('Applicant ${application.studentId.substring(0, 6)}'),
        subtitle: Text(
          'Status: ${application.status}\n${application.coverLetter}',
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            await ref
                .read(applicationControllerProvider.notifier)
                .updateStatus(id: application.id, status: value);
          },
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'pending', child: Text('Mark Pending')),
            PopupMenuItem(value: 'interview', child: Text('Move to Interview')),
            PopupMenuItem(value: 'accepted', child: Text('Accept')),
            PopupMenuItem(value: 'rejected', child: Text('Reject')),
          ],
        ),
      ),
    );
  }
}
