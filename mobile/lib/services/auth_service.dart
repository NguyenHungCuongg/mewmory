import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client;

  AuthService([SupabaseClient? client])
      : _client = client ?? Supabase.instance.client;

  User? get currentUser => _client.auth.currentUser;
  Session? get currentSession => _client.auth.currentSession;
  Stream<AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;

  Future<AuthResponse> signInWithEmail(String email, String password) async {
    return await _client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<AuthResponse> signUpWithEmail(
    String email,
    String password, {
    String? displayName,
  }) async {
    return await _client.auth.signUp(
      email: email.trim(),
      password: password,
      data: displayName != null ? {'full_name': displayName} : null,
    );
  }

  Future<bool> signInWithGoogle() async {
    return await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'com.mewmory.app://login-callback',
    );
  }

  Future<UserResponse> updateDisplayName(String displayName) async {
    final trimmed = displayName.trim();
    final res = await _client.auth.updateUser(
      UserAttributes(
        data: {
          'display_name': trimmed,
          'full_name': trimmed,
        },
      ),
    );

    try {
      final uid = res.user?.id ?? _client.auth.currentUser?.id;
      if (uid != null) {
        await _client.from('profiles').update({
          'display_name': trimmed,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', uid);
      }
    } catch (_) {}

    return res;
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
