class Validators {
  static final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)+$',
  );

  /// Validates email format with optional custom messages
  static String? email(
    String? value, {
    String? emptyMessage,
    String? invalidMessage,
  }) {
    if (value == null || value.trim().isEmpty) {
      return emptyMessage ?? 'Vui lòng nhập email';
    }
    if (!_emailRegExp.hasMatch(value.trim())) {
      return invalidMessage ?? 'Email không hợp lệ';
    }
    return null;
  }

  /// Validates password with optional minLength (default 6) and custom messages
  static String? password(
    String? value, {
    int minLength = 6,
    String? emptyMessage,
    String? minLengthMessage,
  }) {
    if (value == null || value.isEmpty) {
      return emptyMessage ?? 'Vui lòng nhập mật khẩu';
    }
    if (value.length < minLength) {
      return minLengthMessage ?? 'Mật khẩu phải chứa ít nhất $minLength ký tự';
    }
    return null;
  }

  /// Validates required field
  static String? required(String? value, [String fieldName = 'Thông tin này']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName không được để trống';
    }
    return null;
  }

  /// Validates minimum string length
  static String? minLength(
    String? value,
    int min, [
    String fieldName = 'Trường này',
  ]) {
    if (value == null || value.trim().length < min) {
      return '$fieldName phải có ít nhất $min ký tự';
    }
    return null;
  }
}
