import 'dart:convert';
import 'package:drift/drift.dart' show Value;
import 'package:json_annotation/json_annotation.dart';
import '../db/database.dart';

part 'user_settings.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class UserSettings {
  final String id;
  final String userId;
  final String aiProvider;
  final String? aiModel;
  final bool notificationEnabled;
  final String notificationMode;
  final String notificationTime;
  final List<String>? notificationCollections;
  final DateTime updatedAt;

  const UserSettings({
    required this.id,
    required this.userId,
    this.aiProvider = 'gemini',
    this.aiModel,
    this.notificationEnabled = true,
    this.notificationMode = 'gentle',
    this.notificationTime = '09:00',
    this.notificationCollections,
    required this.updatedAt,
  });

  factory UserSettings.fromJson(Map<String, dynamic> json) =>
      _$UserSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$UserSettingsToJson(this);

  UserSettingsTableCompanion toDriftCompanion() {
    return UserSettingsTableCompanion(
      id: Value(id),
      userId: Value(userId),
      aiProvider: Value(aiProvider),
      aiModel: Value(aiModel),
      notificationEnabled: Value(notificationEnabled),
      notificationMode: Value(notificationMode),
      notificationTime: Value(notificationTime),
      notificationCollections: Value(
        notificationCollections != null
            ? jsonEncode(notificationCollections)
            : null,
      ),
      updatedAt: Value(updatedAt),
    );
  }
}
