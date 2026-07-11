import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/data/repositories/auth_repository.dart';
import '../auth/data/repositories/user_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});
