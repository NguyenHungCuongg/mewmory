import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final authStateProvider = StreamProvider<AuthState>((ref) {
  try {
    return Supabase.instance.client.auth.onAuthStateChange;
  } catch (_) {
    return Stream.value(AuthState(AuthChangeEvent.initialSession, null));
  }
});

final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider).asData?.value;
  if (authState?.session?.user != null) {
    return authState!.session!.user;
  }
  try {
    return Supabase.instance.client.auth.currentUser;
  } catch (_) {
    return null;
  }
});

enum SyncState { idle, syncing, completed, failed }

class SyncStateNotifier extends Notifier<SyncState> {
  @override
  SyncState build() => SyncState.idle;

  void setSyncState(SyncState newState) {
    state = newState;
  }
}

final syncStateProvider =
    NotifierProvider<SyncStateNotifier, SyncState>(SyncStateNotifier.new);

