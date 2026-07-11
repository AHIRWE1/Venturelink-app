import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/auth_provider.dart';

class AdminUserState {
  final bool isLoading;
  final String? errorMessage;

  const AdminUserState({this.isLoading = false, this.errorMessage});

  AdminUserState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AdminUserState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Admin-only user management actions. Kept separate from
/// `ProfileController` because that controller always writes a user's full
/// profile payload (name/bio/skills/links) — reusing it here would risk
/// clobbering another user's profile data when all we want to change is
/// their role.
class AdminUserController extends Notifier<AdminUserState> {
  @override
  AdminUserState build() => const AdminUserState();

  Future<bool> updateRole({required String uid, required String role}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await ref.read(userRepositoryProvider).updateUser(uid, {'role': role});
      state = state.copyWith(isLoading: false);
      return true;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to update role.',
      );
      return false;
    }
  }
}

final adminUserControllerProvider =
    NotifierProvider<AdminUserController, AdminUserState>(
      AdminUserController.new,
    );
