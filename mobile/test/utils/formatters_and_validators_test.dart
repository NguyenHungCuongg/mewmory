import 'package:flutter_test/flutter_test.dart';
import 'package:mewmory/utils/formatters.dart';
import 'package:mewmory/utils/validators.dart';

void main() {
  group('Formatters Tests', () {
    test('relativeTime formats various intervals correctly', () {
      final now = DateTime.now();

      expect(
        Formatters.relativeTime(now.subtract(const Duration(seconds: 20))),
        'Vừa xong',
      );
      expect(
        Formatters.relativeTime(now.subtract(const Duration(minutes: 5))),
        '5 phút trước',
      );
      expect(
        Formatters.relativeTime(now.subtract(const Duration(hours: 3))),
        '3 giờ trước',
      );
      expect(
        Formatters.relativeTime(now.subtract(const Duration(days: 1))),
        'Hôm qua',
      );
      expect(
        Formatters.relativeTime(now.subtract(const Duration(days: 4))),
        '4 ngày trước',
      );
    });

    test('cefrLabel maps CEFR levels to Vietnamese descriptive labels', () {
      expect(Formatters.cefrLabel('A1'), 'A1 - Mới bắt đầu (Beginner)');
      expect(Formatters.cefrLabel('A2'), 'A2 - Sơ cấp (Elementary)');
      expect(Formatters.cefrLabel('B1'), 'B1 - Trung cấp (Intermediate)');
      expect(Formatters.cefrLabel('B2'), 'B2 - Trung cao cấp (Upper Intermediate)');
      expect(Formatters.cefrLabel('C1'), 'C1 - Cao cấp (Advanced)');
      expect(Formatters.cefrLabel('C2'), 'C2 - Thành thạo (Proficiency)');
      expect(Formatters.cefrLabel('unknown'), 'unknown');
    });

    test('posLabel translates part of speech to Vietnamese', () {
      expect(Formatters.posLabel('noun'), 'Danh từ');
      expect(Formatters.posLabel('verb'), 'Động từ');
      expect(Formatters.posLabel('adjective'), 'Tính từ');
      expect(Formatters.posLabel('adverb'), 'Trạng từ');
      expect(Formatters.posLabel('preposition'), 'Giới từ');
      expect(Formatters.posLabel('conjunction'), 'Liên từ');
      expect(Formatters.posLabel('idiom'), 'Thành ngữ / Cụm từ');
    });

    test('formatDate and formatDateTime format properly', () {
      final dt = DateTime(2026, 9, 20, 14, 30);
      expect(Formatters.formatDate(dt), '20/09/2026');
      expect(Formatters.formatDateTime(dt), '14:30 20/09/2026');
    });

    test('formatters support English locale', () {
      final now = DateTime.now();
      expect(Formatters.relativeTime(now.subtract(const Duration(seconds: 10)), locale: 'en'), 'Just now');
      expect(Formatters.relativeTime(now.subtract(const Duration(days: 1)), locale: 'en'), 'Yesterday');
      expect(Formatters.cefrLabel('B2', locale: 'en'), 'B2 - Upper Intermediate');
      expect(Formatters.posLabel('adjective', locale: 'en'), 'Adjective');
    });
  });

  group('Validators Tests', () {
    test('email validator accepts valid emails and rejects invalid ones', () {
      expect(Validators.email(null), isNotNull);
      expect(Validators.email(''), isNotNull);
      expect(Validators.email('   '), isNotNull);
      expect(Validators.email('invalid-email'), isNotNull);
      expect(Validators.email('user@domain'), isNotNull);
      expect(Validators.email('user@example.com'), isNull);
      expect(Validators.email('cuong.nguyen@company.co.uk'), isNull);
    });

    test('password validator validates length and non-emptiness', () {
      expect(Validators.password(null), isNotNull);
      expect(Validators.password(''), isNotNull);
      expect(Validators.password('12345'), isNotNull);
      expect(Validators.password('123456'), isNull);
      expect(Validators.password('securePassword123'), isNull);
    });

    test('required validator validates non-empty values', () {
      expect(Validators.required(null, 'Tên'), 'Tên không được để trống');
      expect(Validators.required('', 'Tên'), 'Tên không được để trống');
      expect(Validators.required('   ', 'Tên'), 'Tên không được để trống');
      expect(Validators.required('Học từ vựng', 'Tên'), isNull);
    });

    test('minLength validator validates minimum character count', () {
      expect(Validators.minLength(null, 3, 'Từ'), isNotNull);
      expect(Validators.minLength('ab', 3, 'Từ'), 'Từ phải có ít nhất 3 ký tự');
      expect(Validators.minLength('abc', 3, 'Từ'), isNull);
      expect(Validators.minLength('abcd', 3, 'Từ'), isNull);
    });
  });
}
