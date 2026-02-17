import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../repositories/auth_repository.dart';
import '../models/app_user.dart';

final authRepositoryProvider =
Provider<AuthRepository>((ref) => AuthRepository());

final authStateProvider =
StateNotifierProvider<AuthNotifier, AuthState>(
      (ref) => AuthNotifier(ref),
);

class AuthState {
  final bool isLoading;
  final AppUser? user;
  final String? error;

  AuthState({
    this.isLoading = false,
    this.user,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    AppUser? user,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref ref;

  AuthNotifier(this.ref) : super(AuthState()) {
    ref
        .read(authRepositoryProvider)
        .authStateChanges()
        .listen(_onAuthChanged);
  }

  void _onAuthChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      state = AuthState(user: null);
    } else {
      final profile =
      await ref.read(authRepositoryProvider).getUserProfile();

      state = AuthState(user: profile);
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await ref
          .read(authRepositoryProvider)
          .login(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      state =
          state.copyWith(isLoading: false, error: e.message);
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String username,
    required String gender,
    required String location,
    required DateTime dob,
    required List<String> topics,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await ref.read(authRepositoryProvider).signUp(
        email: email,
        password: password,
        username: username,
        gender: gender,
        location: location,
        dob: dob,
        topics: topics,
      );
    } on FirebaseAuthException catch (e) {
      state =
          state.copyWith(isLoading: false, error: e.message);
    }
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
  }

  Future<void> resetPassword(String email) async {
    await ref
        .read(authRepositoryProvider)
        .resetPassword(email);
  }
}

