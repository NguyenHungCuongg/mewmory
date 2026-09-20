import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/lookup_result.dart';

class LookupException implements Exception {
  final String message;
  const LookupException(this.message);

  @override
  String toString() => message;
}

class LookupService {
  final SupabaseClient? _client;

  LookupService([SupabaseClient? client]) : _client = client;

  SupabaseClient get _supabase => _client ?? Supabase.instance.client;

  Future<LookupResult> lookupWord(
    String word, {
    String? provider,
    String? model,
  }) async {
    final cleanWord = word.trim();
    if (cleanWord.isEmpty) {
      throw const LookupException('Từ vựng không được để trống.');
    }

    try {
      final response = await _supabase.functions.invoke(
        'lookup-word',
        body: {
          'word': cleanWord,
          if (provider != null) 'provider': provider,
          if (model != null) 'model': model,
        },
      );

      if (response.status != 200) {
        final data = response.data;
        final errorMsg = data is Map ? data['error'] : null;
        throw LookupException(errorMsg ?? 'Tra cứu từ vựng thất bại (${response.status})');
      }

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw const LookupException('Định dạng dữ liệu trả về không hợp lệ.');
      }

      return LookupResult.fromJson(data);
    } on LookupException {
      rethrow;
    } catch (e) {
      throw LookupException('Lỗi kết nối khi tra cứu: $e');
    }
  }
}
