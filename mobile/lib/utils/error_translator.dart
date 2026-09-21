import 'dart:convert';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Translates technical exceptions, raw Supabase Auth JSON errors, and
/// network issues into clear, user-friendly Vietnamese messages.
class ErrorTranslator {
  ErrorTranslator._();

  /// Converts any [error] into a human-readable message in Vietnamese or English.
  /// If [prefix] is supplied, formats as "$prefix: $message".
  static String translate(
    dynamic error, {
    String? prefix,
    String locale = 'vi',
  }) {
    final isEn = locale == 'en';
    if (error == null) {
      final fallback = isEn
          ? 'An unexpected error occurred. Please try again.'
          : 'Đã xảy ra lỗi không xác định. Vui lòng thử lại.';
      return prefix != null ? '$prefix: $fallback' : fallback;
    }

    final rawMessage = _extractRawMessage(error);
    final translated = isEn
        ? _mapToEnglish(rawMessage)
        : _mapToVietnamese(rawMessage);

    if (prefix != null && prefix.trim().isNotEmpty) {
      if (translated.toLowerCase().startsWith(prefix.trim().toLowerCase())) {
        return translated;
      }
      return '$prefix: $translated';
    }

    return translated;
  }

  static String _extractRawMessage(dynamic error) {
    if (error is SocketException) {
      return 'network_error';
    }

    if (error is AuthException) {
      // Check if message itself is encoded JSON
      final parsed = _tryExtractJsonMessage(error.message);
      if (parsed != null && parsed.isNotEmpty) {
        return parsed;
      }
      if (error.code != null && error.code!.isNotEmpty) {
        final codeMap = _mapCodeToVietnamese(error.code!);
        if (codeMap != null) return codeMap;
      }
      return error.message;
    }

    if (error is PostgrestException) {
      if (error.code == '23505') {
        return '23505';
      }
      return error.message;
    }

    final str = error.toString().trim();

    // Try parsing string as JSON
    final jsonParsed = _tryExtractJsonMessage(str);
    if (jsonParsed != null && jsonParsed.isNotEmpty) {
      return jsonParsed;
    }

    // Clean up common Dart/Flutter exception wrapper prefixes
    var clean = str;
    if (clean.startsWith('Exception: ')) {
      clean = clean.substring('Exception: '.length).trim();
    }
    if (clean.startsWith('AuthException: ')) {
      clean = clean.substring('AuthException: '.length).trim();
    }

    // AuthException(message: ..., statusCode: ...) regex or extraction
    if (clean.startsWith('AuthException(')) {
      final msgMatch = RegExp(r'message:\s*([^,\)]+)').firstMatch(clean);
      if (msgMatch != null) {
        clean = msgMatch.group(1)?.trim() ?? clean;
      }
    }

    return clean;
  }

  static String? _tryExtractJsonMessage(String input) {
    var candidate = input.trim();
    // Sometimes string contains AuthException(message: {"code":"..."}...)
    final jsonStart = candidate.indexOf('{');
    final jsonEnd = candidate.lastIndexOf('}');
    if (jsonStart != -1 && jsonEnd != -1 && jsonEnd > jsonStart) {
      candidate = candidate.substring(jsonStart, jsonEnd + 1);
    } else {
      return null;
    }

    try {
      final decoded = jsonDecode(candidate);
      if (decoded is Map<String, dynamic>) {
        // Priority to error_description or message or code
        final errorDescription = decoded['error_description'] as String?;
        if (errorDescription != null && errorDescription.isNotEmpty) {
          return errorDescription;
        }

        final message = decoded['message'] as String?;
        if (message != null && message.isNotEmpty) {
          return message;
        }

        final code = decoded['code'] as String? ?? decoded['error'] as String?;
        if (code != null && code.isNotEmpty) {
          return code;
        }
      }
    } catch (_) {}

    return null;
  }

  static String? _mapCodeToVietnamese(String code) {
    final lower = code.toLowerCase();
    switch (lower) {
      case 'invalid_credentials':
      case 'invalid_grant':
        return 'Email hoặc mật khẩu không chính xác.';
      case 'user_already_exists':
        return 'Email này đã được đăng ký. Vui lòng đăng nhập.';
      case 'email_not_confirmed':
        return 'Email chưa được xác nhận. Vui lòng kiểm tra hộp thư để kích hoạt tài khoản.';
      case 'over_email_send_rate_limit':
        return 'Quá nhiều yêu cầu gửi email. Vui lòng thử lại sau giây lát.';
      default:
        return null;
    }
  }

  static String _mapToVietnamese(String message) {
    final lower = message.toLowerCase().trim();

    if (lower.isEmpty) {
      return 'Đã xảy ra lỗi không xác định. Vui lòng thử lại.';
    }

    // Network & connectivity errors
    if (lower == 'network_error' ||
        lower.contains('failed host lookup') ||
        lower.contains('socketexception') ||
        lower.contains('clientexception') ||
        lower.contains('network is unreachable') ||
        lower.contains('connection refused') ||
        lower.contains('connection closed') ||
        lower.contains('connection timed out') ||
        lower.contains('software caused connection abort')) {
      return 'Không thể kết nối máy chủ. Vui lòng kiểm tra lại kết nối mạng.';
    }

    // Postgrest duplicate unique constraint
    if (lower.contains('23505') ||
        lower.contains('duplicate key value') ||
        lower.contains('already exists')) {
      return 'Dữ liệu đã tồn tại trong hệ thống.';
    }

    // Wrong credentials
    if (lower.contains('invalid login credentials') ||
        lower.contains('invalid credentials') ||
        lower.contains('invalid_credentials') ||
        lower.contains('invalid_grant') ||
        lower.contains('wrong password') ||
        lower.contains('invalid email or password')) {
      return 'Email hoặc mật khẩu không chính xác.';
    }

    // Already registered
    if (lower.contains('user already registered') ||
        lower.contains('already registered') ||
        lower.contains('already in use') ||
        lower.contains('user_already_exists')) {
      return 'Email này đã được đăng ký. Vui lòng đăng nhập.';
    }

    // Email not confirmed
    if (lower.contains('email not confirmed')) {
      return 'Email chưa được xác nhận. Vui lòng kiểm tra hộp thư để kích hoạt tài khoản.';
    }

    // Password short / invalid
    if (lower.contains('password should be at least') ||
        lower.contains('password is too short')) {
      return 'Mật khẩu phải có ít nhất 6 ký tự.';
    }
    if (lower.contains('signup requires a valid password')) {
      return 'Vui lòng nhập mật khẩu hợp lệ.';
    }

    // Rate limits
    if (lower.contains('rate limit') ||
        lower.contains('too many requests') ||
        lower.contains('over_email_send_rate_limit') ||
        lower.contains('email rate limit exceeded')) {
      return 'Quá nhiều yêu cầu. Vui lòng thử lại sau giây lát.';
    }

    // Database / Server
    if (lower.contains('database error saving new user')) {
      return 'Lỗi cơ sở dữ liệu khi tạo tài khoản. Vui lòng thử lại sau.';
    }

    // Invalid email
    if (lower.contains('invalid email') ||
        lower.contains('unable to validate email')) {
      return 'Địa chỉ email không hợp lệ.';
    }

    // Session expired
    if (lower.contains('jwt expired') ||
        lower.contains('token is expired') ||
        lower.contains('session expired')) {
      return 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.';
    }

    // If string still looks like JSON or code, strip it
    if (message.startsWith('{') && message.endsWith('}')) {
      return 'Đã xảy ra lỗi không xác định. Vui lòng thử lại.';
    }

    return message;
  }

  static String _mapToEnglish(String message) {
    final lower = message.toLowerCase().trim();

    if (lower.isEmpty) {
      return 'An unexpected error occurred. Please try again.';
    }

    // Network & connectivity errors
    if (lower == 'network_error' ||
        lower.contains('failed host lookup') ||
        lower.contains('socketexception') ||
        lower.contains('clientexception') ||
        lower.contains('network is unreachable') ||
        lower.contains('connection refused') ||
        lower.contains('connection closed') ||
        lower.contains('connection timed out') ||
        lower.contains('software caused connection abort')) {
      return 'Cannot connect to server. Please check your network connection.';
    }

    // Postgrest duplicate unique constraint
    if (lower.contains('23505') ||
        lower.contains('duplicate key value') ||
        lower.contains('already exists')) {
      return 'Data already exists in the system.';
    }

    // Wrong credentials
    if (lower.contains('invalid login credentials') ||
        lower.contains('invalid credentials') ||
        lower.contains('invalid_credentials') ||
        lower.contains('invalid_grant') ||
        lower.contains('wrong password') ||
        lower.contains('invalid email or password')) {
      return 'Incorrect email or password.';
    }

    // Already registered
    if (lower.contains('user already registered') ||
        lower.contains('already registered') ||
        lower.contains('already in use') ||
        lower.contains('user_already_exists')) {
      return 'This email is already registered. Please sign in.';
    }

    // Email not confirmed
    if (lower.contains('email not confirmed')) {
      return 'Email not confirmed. Please check your inbox to activate your account.';
    }

    // Password short / invalid
    if (lower.contains('password should be at least') ||
        lower.contains('password is too short')) {
      return 'Password must be at least 6 characters.';
    }
    if (lower.contains('signup requires a valid password')) {
      return 'Please enter a valid password.';
    }

    // Rate limits
    if (lower.contains('rate limit') ||
        lower.contains('too many requests') ||
        lower.contains('over_email_send_rate_limit') ||
        lower.contains('email rate limit exceeded')) {
      return 'Too many requests. Please try again later.';
    }

    // Database / Server
    if (lower.contains('database error saving new user')) {
      return 'Database error creating account. Please try again later.';
    }

    // Invalid email
    if (lower.contains('invalid email') ||
        lower.contains('unable to validate email')) {
      return 'Invalid email address.';
    }

    // Session expired
    if (lower.contains('jwt expired') ||
        lower.contains('token is expired') ||
        lower.contains('session expired')) {
      return 'Session expired. Please sign in again.';
    }

    // If string still looks like JSON or code, strip it
    if (message.startsWith('{') && message.endsWith('}')) {
      return 'An unexpected error occurred. Please try again.';
    }

    return message;
  }
}
