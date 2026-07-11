import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/firestore_constants.dart';
import '../../../providers/auth_provider.dart';

class OnboardingState {
  final bool isLoading;
  final String? errorMessage;

  const OnboardingState({this.isLoading = false, this.errorMessage});

  OnboardingState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return OnboardingState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class OnboardingController extends Notifier<OnboardingState> {
  @override
  OnboardingState build() => const OnboardingState();

  Future<bool> submit({
    required String uid,
    required String name,
    required String role,
    required List<String> skills,
    required String bio,
    String? githubUrl,
    String? linkedinUrl,
    String? websiteUrl,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await ref
          .read(userRepositoryProvider)
          .completeOnboarding(
            uid: uid,
            name: name.trim(),
            role: role,
            skills: skills,
            bio: bio.trim(),
            githubUrl: _normalizeUrl(githubUrl),
            linkedinUrl: _normalizeUrl(linkedinUrl),
            websiteUrl: _normalizeUrl(websiteUrl),
          );
      state = state.copyWith(isLoading: false);
      return true;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to save profile. Please try again.',
      );
      return false;
    }
  }

  String? _normalizeUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    return value.trim();
  }
}

final onboardingControllerProvider =
    NotifierProvider<OnboardingController, OnboardingState>(
      OnboardingController.new,
    );

String dashboardRouteForRole(String role) {
  switch (role) {
    case UserRoles.admin:
      return AppRoutes.adminDashboard;
    case UserRoles.founder:
      return AppRoutes.founderDashboard;
    case UserRoles.student:
    default:
      return AppRoutes.studentDashboard;
  }
}
