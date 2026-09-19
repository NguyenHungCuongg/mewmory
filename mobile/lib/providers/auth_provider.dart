import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final authStateProvider = StreamProvider<AuthState>((ref) {
  try {
    return Supabase.instance.client.auth.onAuthStateChange;
  } catch (_) {
    return Stream.value(AuthState(AuthChangeEvent.initialSession, null));
  }
});

final currentUserProvider = Provider<User?>((ref) {
  try {
    return Supabase.instance.client.auth.currentUser;
  } catch (_) {
    return null;
  }
});
