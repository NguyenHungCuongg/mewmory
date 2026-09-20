class Validators {
  static final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)+$',
  );

  /// Validates email format
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập email';
    }
    if (!_emailRegExp.hasMatch(value.trim())) {
      return 'Email không hợp lệ';
    }
    return null;
  }

  /// Validates password with optional minLength (default 6)
  static String? password(String? value, {int minLength = 6}) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }
    if (value.length < minLength) {
      return 'Mật khẩu phải chứa ít nhất $minLength ký tự';
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
