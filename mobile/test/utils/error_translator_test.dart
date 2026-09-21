import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mewmory/utils/error_translator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('ErrorTranslator Tests', () {
    test('translates invalid login credentials to friendly Vietnamese', () {
      const error = AuthException('Invalid login credentials', statusCode: '400');
      expect(
        ErrorTranslator.translate(error),
        'Email hoặc mật khẩu không chính xác.',
      );
    });

    test('translates raw JSON string with invalid_credentials code', () {
      const rawJson = '{"code":"invalid_credentials","message":"Invalid login credentials"}';
      expect(
        ErrorTranslator.translate(rawJson),
        'Email hoặc mật khẩu không chính xác.',
      );
    });

    test('translates error_description in json object', () {
      const rawJson = '{"error":"invalid_grant","error_description":"Invalid login credentials"}';
      expect(
        ErrorTranslator.translate(rawJson),
        'Email hoặc mật khẩu không chính xác.',
      );
    });

    test('translates user already registered', () {
      const error = AuthException('User already registered', statusCode: '422');
      expect(
        ErrorTranslator.translate(error),
        'Email này đã được đăng ký. Vui lòng đăng nhập.',
      );
    });

    test('translates email not confirmed', () {
      const error = AuthException('Email not confirmed', statusCode: '400');
      expect(
        ErrorTranslator.translate(error),
        'Email chưa được xác nhận. Vui lòng kiểm tra hộp thư để kích hoạt tài khoản.',
      );
    });

    test('translates password too short', () {
      const error = AuthException('Password should be at least 6 characters');
      expect(
        ErrorTranslator.translate(error),
        'Mật khẩu phải có ít nhất 6 ký tự.',
      );
    });

    test('translates rate limit error', () {
      const error = AuthException('over_email_send_rate_limit: email rate limit exceeded');
      expect(
        ErrorTranslator.translate(error),
        'Quá nhiều yêu cầu. Vui lòng thử lại sau giây lát.',
      );
    });

    test('translates network / socket exception', () {
      const error = SocketException('Failed host lookup: api.supabase.com');
      expect(
        ErrorTranslator.translate(error),
        'Không thể kết nối máy chủ. Vui lòng kiểm tra lại kết nối mạng.',
      );
    });

    test('translates postgrest unique constraint violation', () {
      const error = PostgrestException(
        message: 'duplicate key value violates unique constraint',
        code: '23505',
      );
      expect(
        ErrorTranslator.translate(error),
        'Dữ liệu đã tồn tại trong hệ thống.',
      );
    });

    test('formats with custom prefix when provided', () {
      const error = AuthException('Invalid login credentials');
      expect(
        ErrorTranslator.translate(error, prefix: 'Đăng nhập thất bại'),
        'Đăng nhập thất bại: Email hoặc mật khẩu không chính xác.',
      );
    });

    test('strips technical Exception prefixes on unknown errors', () {
      final error = Exception('Tên bộ từ không được để trống');
      expect(
        ErrorTranslator.translate(error),
        'Tên bộ từ không được để trống',
      );
    });

    test('handles null or empty error gracefully', () {
      expect(
        ErrorTranslator.translate(null),
        'Đã xảy ra lỗi không xác định. Vui lòng thử lại.',
      );
      expect(
        ErrorTranslator.translate(''),
        'Đã xảy ra lỗi không xác định. Vui lòng thử lại.',
      );
    });

    test('translates invalid login credentials to English when locale is en', () {
      const error = AuthException('Invalid login credentials', statusCode: '400');
      expect(
        ErrorTranslator.translate(error, locale: 'en'),
        'Incorrect email or password.',
      );
    });

    test('translates user already registered to English when locale is en', () {
      const error = AuthException('User already registered', statusCode: '422');
      expect(
        ErrorTranslator.translate(error, locale: 'en', prefix: 'Registration failed'),
        'Registration failed: This email is already registered. Please sign in.',
      );
    });

    test('translates network error to English when locale is en', () {
      const error = SocketException('Failed host lookup');
      expect(
        ErrorTranslator.translate(error, locale: 'en'),
        'Cannot connect to server. Please check your network connection.',
      );
    });
  });
}
