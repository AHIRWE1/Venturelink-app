import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../shared/models/startup.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../data/startup_repository.dart';

final startupRepositoryProvider = Provider<StartupRepository>((ref) {
  return StartupRepository();
});

final startupListProvider = StreamProvider<List<Startup>>((ref) {
  final user = ref.watch(currentAppUserProvider).value;
  if (user == null) {
    return const Stream.empty();
  }

  return ref
      .watch(startupRepositoryProvider)
      .watchStartups(ownerId: user.role == 'founder' ? user.uid : null);
});

final startupByIdProvider = FutureProvider.family<Startup?, String>((
  ref,
  startupId,
) {
  return ref.read(startupRepositoryProvider).getStartupById(startupId);
});

final startupByOwnerProvider = FutureProvider.family<Startup?, String>((
  ref,
  ownerId,
) {
  return ref.read(startupRepositoryProvider).getStartupByOwner(ownerId);
});

class StartupFormState {
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  const StartupFormState({
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  StartupFormState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return StartupFormState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess
          ? null
          : (successMessage ?? this.successMessage),
    );
  }
}

class StartupController extends Notifier<StartupFormState> {
  @override
  StartupFormState build() => const StartupFormState();

  Future<bool> createStartup({
    required String ownerId,
    required String startupName,
    required String description,
    required String industry,
    required int teamSize,
    required String website,
  }) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccess: true,
    );
    try {
      final startup = Startup(
        id: const Uuid().v4(),
        ownerId: ownerId,
        startupName: startupName.trim(),
        description: description.trim(),
        industry: industry.trim(),
        teamSize: teamSize,
        website: website.trim(),
        verificationStatus: 'pending',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await ref.read(startupRepositoryProvider).createStartup(startup);
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Startup created',
      );
      return true;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to create startup.',
      );
      return false;
    }
  }

  Future<bool> updateStartup({
    required String id,
    required String startupName,
    required String description,
    required String industry,
    required int teamSize,
    required String website,
    required String verificationStatus,
  }) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccess: true,
    );
    try {
      await ref.read(startupRepositoryProvider).updateStartup(id, {
        'startupName': startupName.trim(),
        'description': description.trim(),
        'industry': industry.trim(),
        'teamSize': teamSize,
        'website': website.trim(),
        'verificationStatus': verificationStatus,
      });
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Startup updated',
      );
      return true;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to update startup.',
      );
      return false;
    }
  }

  /// Admin-only partial update used by the startup verification screen —
  /// flips just the verification status without requiring the full profile
  /// payload that [updateStartup] expects.
  Future<bool> updateVerificationStatus({
    required String id,
    required String status,
  }) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccess: true,
    );
    try {
      await ref.read(startupRepositoryProvider).updateStartup(id, {
        'verificationStatus': status,
      });
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Startup status updated',
      );
      return true;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to update verification status.',
      );
      return false;
    }
  }

  Future<bool> deleteStartup(String id) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccess: true,
    );
    try {
      await ref.read(startupRepositoryProvider).deleteStartup(id);
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Startup deleted',
      );
      return true;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to delete startup.',
      );
      return false;
    }
  }

  void clearFeedback() {
    state = state.copyWith(clearError: true, clearSuccess: true);
  }
}

final startupControllerProvider =
    NotifierProvider<StartupController, StartupFormState>(
      StartupController.new,
    );
