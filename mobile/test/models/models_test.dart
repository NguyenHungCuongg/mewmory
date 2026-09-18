import 'package:flutter_test/flutter_test.dart';
import 'package:mewmory/models/vocabulary.dart';
import 'package:mewmory/models/definition.dart';
import 'package:mewmory/models/collection.dart';
import 'package:mewmory/models/user_settings.dart';
import 'package:mewmory/models/profile.dart';
import 'package:mewmory/models/lookup_result.dart';

void main() {
  group('JSON Models & Drift Companions', () {
    test('Definition model - fromJson, toJson, and toDriftCompanion', () {
      final json = {
        'id': 'def-1',
        'vocabulary_id': 'vocab-1',
        'definition_en': 'Able to recover quickly.',
        'definition_vi': 'Kiên cường.',
        'example': 'A resilient spirit.',
        'sort_order': 1,
        'created_at': '2026-09-18T10:00:00.000Z',
        'updated_at': '2026-09-18T10:00:00.000Z',
        'is_deleted': false,
      };

      final def = Definition.fromJson(json);
      expect(def.id, 'def-1');
      expect(def.vocabularyId, 'vocab-1');
      expect(def.definitionVi, 'Kiên cường.');
      expect(def.sortOrder, 1);

      final companion = def.toDriftCompanion();
      expect(companion.id.value, 'def-1');
      expect(companion.vocabularyId.value, 'vocab-1');
      expect(companion.definitionVi.value, 'Kiên cường.');

      final outputJson = def.toJson();
      expect(outputJson['definition_vi'], 'Kiên cường.');
      expect(outputJson['sort_order'], 1);
    });

    test('Vocabulary model - fromJson, toJson, and toDriftCompanion', () {
      final json = {
        'id': 'v-1',
        'user_id': 'u-1',
        'word': 'resilient',
        'phonetic': '/rɪˈzɪliənt/',
        'audio_url': 'https://example.com/audio.mp3',
        'part_of_speech': 'adjective',
        'cefr_level': 'B2',
        'usage_register': 'formal',
        'created_at': '2026-09-18T10:00:00.000Z',
        'updated_at': '2026-09-18T10:00:00.000Z',
        'is_deleted': false,
        'definitions': [
          {
            'id': 'def-1',
            'vocabulary_id': 'v-1',
            'definition_en': 'Able to recover quickly.',
            'definition_vi': 'Kiên cường.',
            'sort_order': 0,
            'created_at': '2026-09-18T10:00:00.000Z',
            'updated_at': '2026-09-18T10:00:00.000Z',
            'is_deleted': false,
          },
        ],
      };

      final vocab = Vocabulary.fromJson(json);
      expect(vocab.word, 'resilient');
      expect(vocab.cefrLevel, 'B2');
      expect(vocab.definitions?.length, 1);
      expect(vocab.definitions?.first.definitionVi, 'Kiên cường.');

      final companion = vocab.toDriftCompanion();
      expect(companion.id.value, 'v-1');
      expect(companion.word.value, 'resilient');
      expect(companion.cefrLevel.value, 'B2');
    });

    test('Collection model - fromJson, toJson, and toDriftCompanion', () {
      final json = {
        'id': 'c-1',
        'user_id': 'u-1',
        'name': 'IELTS Writing',
        'description': 'Vocab for essay writing',
        'is_default': false,
        'is_ai_generated': true,
        'created_at': '2026-09-18T10:00:00.000Z',
        'updated_at': '2026-09-18T10:00:00.000Z',
        'is_deleted': false,
      };

      final col = Collection.fromJson(json);
      expect(col.name, 'IELTS Writing');
      expect(col.isAiGenerated, true);

      final companion = col.toDriftCompanion();
      expect(companion.name.value, 'IELTS Writing');
      expect(companion.isAiGenerated.value, true);
    });

    test('UserSettings model - fromJson, toJson, and toDriftCompanion', () {
      final json = {
        'id': 's-1',
        'user_id': 'u-1',
        'ai_provider': 'openrouter',
        'ai_model': 'deepseek-chat',
        'notification_enabled': true,
        'notification_mode': 'quiz',
        'notification_time': '08:30',
        'notification_collections': ['c-1', 'c-2'],
        'updated_at': '2026-09-18T10:00:00.000Z',
      };

      final settings = UserSettings.fromJson(json);
      expect(settings.aiProvider, 'openrouter');
      expect(settings.aiModel, 'deepseek-chat');
      expect(settings.notificationCollections, ['c-1', 'c-2']);

      final companion = settings.toDriftCompanion();
      expect(companion.aiProvider.value, 'openrouter');
      expect(companion.notificationCollections.value, '["c-1","c-2"]');
    });

    test('Profile model - fromJson and toJson', () {
      final json = {
        'id': 'p-1',
        'email': 'user@example.com',
        'display_name': 'Test User',
        'avatar_url': 'https://example.com/avatar.png',
        'created_at': '2026-09-18T10:00:00.000Z',
        'updated_at': '2026-09-18T10:00:00.000Z',
      };

      final profile = Profile.fromJson(json);
      expect(profile.email, 'user@example.com');
      expect(profile.displayName, 'Test User');
    });

    test('LookupResult model - parsing Edge Function response', () {
      final json = {
        'word': 'resilient',
        'phonetic': '/rɪˈzɪliənt/',
        'audio_url': 'https://api.dictionaryapi.dev/audio.mp3',
        'meanings': [
          {
            'part_of_speech': 'adjective',
            'cefr_level': 'C1',
            'usage_register': 'formal',
            'definitions': [
              {
                'definition_en': 'able to recover quickly',
                'definition_vi': 'kiên cường',
                'example': 'She is resilient.',
                'synonyms': ['tough', 'strong'],
                'antonyms': ['fragile'],
              },
            ],
          },
        ],
        'suggested_collections': ['Personality', 'IELTS Writing'],
        'source': {
          'dictionary': true,
          'ai': true,
        },
      };

      final result = LookupResult.fromJson(json);
      expect(result.word, 'resilient');
      expect(result.meanings.length, 1);
      expect(result.meanings.first.partOfSpeech, 'adjective');
      expect(result.meanings.first.definitions.length, 1);
      expect(result.meanings.first.definitions.first.definitionVi, 'kiên cường');
      expect(result.suggestedCollections, ['Personality', 'IELTS Writing']);
      expect(result.source?.dictionary, true);
      expect(result.source?.ai, true);
    });
  });
}
