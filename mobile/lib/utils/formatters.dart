import 'package:intl/intl.dart';

class Formatters {
  static final DateFormat _dateFormatter = DateFormat('dd/MM/yyyy');
  static final DateFormat _dateTimeFormatter = DateFormat('HH:mm dd/MM/yyyy');

  /// Formats date to relative string ("Vừa xong", "5 phút trước", "Just now", "5 mins ago"...)
  static String relativeTime(DateTime dateTime, {String locale = 'vi'}) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    final isEn = locale.startsWith('en');

    if (difference.inSeconds < 60) {
      return isEn ? 'Just now' : 'Vừa xong';
    } else if (difference.inMinutes < 60) {
      final m = difference.inMinutes;
      return isEn ? '$m min${m > 1 ? 's' : ''} ago' : '$m phút trước';
    } else if (difference.inHours < 24) {
      final h = difference.inHours;
      return isEn ? '$h hr${h > 1 ? 's' : ''} ago' : '$h giờ trước';
    } else if (difference.inDays == 1) {
      return isEn ? 'Yesterday' : 'Hôm qua';
    } else if (difference.inDays < 7) {
      final d = difference.inDays;
      return isEn ? '$d days ago' : '$d ngày trước';
    } else {
      return _dateFormatter.format(dateTime);
    }
  }

  /// CEFR level label with explanation
  static String cefrLabel(String level, {String locale = 'vi'}) {
    final normalized = level.toUpperCase().trim();
    final isEn = locale.startsWith('en');

    if (isEn) {
      switch (normalized) {
        case 'A1':
          return 'A1 - Beginner';
        case 'A2':
          return 'A2 - Elementary';
        case 'B1':
          return 'B1 - Intermediate';
        case 'B2':
          return 'B2 - Upper Intermediate';
        case 'C1':
          return 'C1 - Advanced';
        case 'C2':
          return 'C2 - Proficiency';
        default:
          return level;
      }
    }

    switch (normalized) {
      case 'A1':
        return 'A1 - Mới bắt đầu (Beginner)';
      case 'A2':
        return 'A2 - Sơ cấp (Elementary)';
      case 'B1':
        return 'B1 - Trung cấp (Intermediate)';
      case 'B2':
        return 'B2 - Trung cao cấp (Upper Intermediate)';
      case 'C1':
        return 'C1 - Cao cấp (Advanced)';
      case 'C2':
        return 'C2 - Thành thạo (Proficiency)';
      default:
        return level;
    }
  }

  /// Translation for part of speech
  static String posLabel(String pos, {String locale = 'vi'}) {
    final normalized = pos.toLowerCase().trim();
    final isEn = locale.startsWith('en');

    if (isEn) {
      switch (normalized) {
        case 'noun':
        case 'n':
          return 'Noun';
        case 'verb':
        case 'v':
          return 'Verb';
        case 'adjective':
        case 'adj':
          return 'Adjective';
        case 'adverb':
        case 'adv':
          return 'Adverb';
        case 'preposition':
        case 'prep':
          return 'Preposition';
        case 'conjunction':
        case 'conj':
          return 'Conjunction';
        case 'interjection':
          return 'Interjection';
        case 'pronoun':
          return 'Pronoun';
        case 'phrase':
        case 'idiom':
          return 'Phrase / Idiom';
        default:
          if (pos.isEmpty) return pos;
          return pos[0].toUpperCase() + pos.substring(1);
      }
    }

    switch (normalized) {
      case 'noun':
      case 'n':
        return 'Danh từ';
      case 'verb':
      case 'v':
        return 'Động từ';
      case 'adjective':
      case 'adj':
        return 'Tính từ';
      case 'adverb':
      case 'adv':
        return 'Trạng từ';
      case 'preposition':
      case 'prep':
        return 'Giới từ';
      case 'conjunction':
      case 'conj':
        return 'Liên từ';
      case 'interjection':
        return 'Thán từ';
      case 'pronoun':
        return 'Đại từ';
      case 'phrase':
      case 'idiom':
        return 'Thành ngữ / Cụm từ';
      default:
        if (pos.isEmpty) return pos;
        return pos[0].toUpperCase() + pos.substring(1);
    }
  }

  /// Formats date to dd/MM/yyyy
  static String formatDate(DateTime dateTime) {
    return _dateFormatter.format(dateTime);
  }

  /// Formats date to HH:mm dd/MM/yyyy
  static String formatDateTime(DateTime dateTime) {
    return _dateTimeFormatter.format(dateTime);
  }
}
