import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/auth_provider.dart';

class ProfileFormState {
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  const ProfileFormState({
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  ProfileFormState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return ProfileFormState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess
          ? null
          : (successMessage ?? this.successMessage),
    );
  }
}

class ProfileController extends Notifier<ProfileFormState> {
  @override
  ProfileFormState build() => const ProfileFormState();

  Future<bool> updateProfile({
    required String uid,
    required String name,
    required String bio,
    required List<String> skills,
    String? githubUrl,
    String? linkedinUrl,
    String? websiteUrl,
  }) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccess: true,
    );

    try {
      await ref.read(userRepositoryProvider).updateUser(uid, {
        'name': name.trim(),
        'bio': bio.trim(),
        'skills': skills,
        'githubUrl': githubUrl?.trim() ?? '',
        'linkedinUrl': linkedinUrl?.trim() ?? '',
        'websiteUrl': websiteUrl?.trim() ?? '',
      });
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Profile updated',
      );
      return true;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to update your profile.',
      );
      return false;
    }
  }
}

final profileControllerProvider =
    NotifierProvider<ProfileController, ProfileFormState>(
      ProfileController.new,
    );
