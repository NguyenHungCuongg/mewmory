import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/user_settings.dart';
import 'auth_provider.dart';
import 'services_provider.dart';

final userSettingsProvider =
    FutureProvider.family<UserSettings?, String>((ref, userId) {
  final service = ref.watch(settingsServiceProvider);
  return service.get(userId);
});

class UserSettingsNotifier extends AsyncNotifier<UserSettings?> {
  @override
  Future<UserSettings?> build() async {
    final user = ref.watch(currentUserProvider);
    if (user == null) return null;
    final service = ref.watch(settingsServiceProvider);
    return service.get(user.id);
  }

  Future<void> updateAiSettings({
    required String aiProvider,
    String? aiModel,
  }) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    final current = state.value;
    final updated = (current != null)
        ? current.copyWith(
            aiProvider: aiProvider,
            aiModel: aiModel,
            updatedAt: DateTime.now(),
          )
        : UserSettings(
            id: const Uuid().v4(),
            userId: user.id,
            aiProvider: aiProvider,
            aiModel: aiModel,
            updatedAt: DateTime.now(),
          );

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(settingsServiceProvider).update(updated);
      return updated;
    });
  }
}

final userSettingsNotifierProvider =
    AsyncNotifierProvider<UserSettingsNotifier, UserSettings?>(
  UserSettingsNotifier.new,
);
