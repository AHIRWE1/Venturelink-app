import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../shared/models/application.dart';
import '../../data/application_repository.dart';

final applicationRepositoryProvider = Provider<ApplicationRepository>((ref) {
  return ApplicationRepository();
});

final studentApplicationsProvider =
    StreamProvider.family<List<ApplicationModel>, String>((ref, studentId) {
      return ref
          .watch(applicationRepositoryProvider)
          .watchApplicationsForStudent(studentId);
    });

final startupApplicationsProvider =
    StreamProvider.family<List<ApplicationModel>, String>((ref, startupId) {
      return ref
          .watch(applicationRepositoryProvider)
          .watchApplicationsForStartup(startupId);
    });

class ApplicationFormState {
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  const ApplicationFormState({
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  ApplicationFormState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return ApplicationFormState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess
          ? null
          : (successMessage ?? this.successMessage),
    );
  }
}

class ApplicationController extends Notifier<ApplicationFormState> {
  @override
  ApplicationFormState build() => const ApplicationFormState();

  Future<bool> apply({
    required String studentId,
    required String startupId,
    required String opportunityId,
    required String coverLetter,
  }) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccess: true,
    );
    try {
      final application = ApplicationModel(
        id: const Uuid().v4(),
        studentId: studentId,
        startupId: startupId,
        opportunityId: opportunityId,
        status: 'pending',
        coverLetter: coverLetter.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await ref
          .read(applicationRepositoryProvider)
          .createApplication(application);
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Application submitted',
      );
      return true;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to submit application.',
      );
      return false;
    }
  }

  Future<bool> updateStatus({
    required String id,
    required String status,
  }) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccess: true,
    );
    try {
      await ref.read(applicationRepositoryProvider).updateApplication(id, {
        'status': status,
      });
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Application updated',
      );
      return true;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to update application.',
      );
      return false;
    }
  }

  Future<bool> withdraw(String id) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccess: true,
    );
    try {
      await ref.read(applicationRepositoryProvider).deleteApplication(id);
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Application withdrawn',
      );
      return true;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to withdraw application.',
      );
      return false;
    }
  }
}

final applicationControllerProvider =
    NotifierProvider<ApplicationController, ApplicationFormState>(
      ApplicationController.new,
    );
