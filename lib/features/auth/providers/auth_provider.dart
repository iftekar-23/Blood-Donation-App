import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';

part 'auth_provider.g.dart';

/// Stream of Firebase auth state (null = logged out)
@riverpod
Stream<User?> authState(AuthStateRef ref) {
  return FirebaseAuth.instance.authStateChanges();
}

/// Current user's Firestore profile
@riverpod
Future<UserModel?> currentUserProfile(CurrentUserProfileRef ref) async {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return null;
  final service = ref.read(authServiceProvider);
  return service.getUserProfile(user.uid);
}
