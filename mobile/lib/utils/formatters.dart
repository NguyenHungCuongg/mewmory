import 'package:intl/intl.dart';

class Formatters {
  static final DateFormat _dateFormatter = DateFormat('dd/MM/yyyy');
  static final DateFormat _dateTimeFormatter = DateFormat('HH:mm dd/MM/yyyy');

  /// Formats date to relative string ("Vừa xong", "5 phút trước", "Hôm qua"...)
  static String relativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Vừa xong';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays == 1) {
      return 'Hôm qua';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return _dateFormatter.format(dateTime);
    }
  }

  /// CEFR level label with explanation
  static String cefrLabel(String level) {
    switch (level.toUpperCase().trim()) {
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

  /// Vietnamese translation for part of speech
  static String posLabel(String pos) {
    final normalized = pos.toLowerCase().trim();
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
