import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/auth_exception_mapper.dart';
import '../../../../shared/models/app_user.dart';
import '../../../providers/auth_provider.dart';

final authStateChangesProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

final currentAppUserProvider = StreamProvider<AppUser?>((ref) {
  final firebaseUser = ref.watch(authStateChangesProvider).value;

  if (firebaseUser == null) {
    return Stream.value(null);
  }

  return ref.watch(userRepositoryProvider).watchUser(firebaseUser.uid);
});

final allUsersProvider = StreamProvider<List<AppUser>>((ref) {
  return ref.watch(userRepositoryProvider).watchAllUsers();
});

class AuthActionState {
  final bool isLoading;
  final String? errorMessage;

  const AuthActionState({
    this.isLoading = false,
    this.errorMessage,
  });

  AuthActionState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthActionState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class AuthController extends Notifier<AuthActionState> {
  @override
  AuthActionState build() => const AuthActionState();

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await ref.read(authRepositoryProvider).signIn(
            email: email.trim().toLowerCase(),
            password: password,
          );
      state = state.copyWith(isLoading: false);
      return true;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: mapFirebaseAuthException(e),
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Something went wrong. Please try again.',
      );
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final credential = await ref.read(authRepositoryProvider).register(
            email: email.trim().toLowerCase(),
            password: password,
          );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw const AuthException('Registration failed. Please try again.');
      }

      final appUser = AppUser.initial(
        uid: firebaseUser.uid,
        email: email.trim().toLowerCase(),
      );

      await ref.read(userRepositoryProvider).createUser(appUser);

      state = state.copyWith(isLoading: false);
      return true;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: mapFirebaseAuthException(e),
      );
      return false;
    } on AuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Registration failed. Please try again.',
      );
      return false;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await ref.read(authRepositoryProvider).signOut();
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

final authControllerProvider =
    NotifierProvider<AuthController, AuthActionState>(AuthController.new);
