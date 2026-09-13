/**
 * Map Supabase auth errors to user-friendly Vietnamese messages.
 * @param {Error|{message?: string, code?: string}|string} error
 * @returns {string}
 */
export function getAuthErrorMessage(error) {
  if (!error) return "Đã xảy ra lỗi không xác định.";

  if (typeof error === "string") {
    return translateMessage(error);
  }

  if (error.code === "user_already_exists") {
    return (
      error.message ||
      "Email này đã được đăng ký. Vui lòng đăng nhập bằng mật khẩu của bạn."
    );
  }

  const rawMessage = error.message || "";
  return translateMessage(rawMessage);
}

function translateMessage(rawMessage) {
  const lower = rawMessage.toLowerCase();

  if (
    lower.includes("user already registered") ||
    lower.includes("already registered") ||
    lower.includes("already in use") ||
    lower.includes("user_already_exists")
  ) {
    return "Email này đã được đăng ký. Vui lòng đăng nhập bằng mật khẩu của bạn.";
  }

  if (
    lower.includes("invalid login credentials") ||
    lower.includes("invalid credentials") ||
    lower.includes("wrong password")
  ) {
    return "Email hoặc mật khẩu không chính xác.";
  }

  if (lower.includes("email not confirmed")) {
    return "Email chưa được xác nhận. Vui lòng kiểm tra hộp thư để kích hoạt tài khoản.";
  }

  if (
    lower.includes("password should be at least") ||
    lower.includes("password is too short")
  ) {
    return "Mật khẩu phải có ít nhất 6 ký tự.";
  }

  if (lower.includes("rate limit") || lower.includes("too many requests")) {
    return "Quá nhiều yêu cầu. Vui lòng thử lại sau giây lát.";
  }

  if (
    lower.includes("invalid email") ||
    lower.includes("unable to validate email")
  ) {
    return "Địa chỉ email không hợp lệ.";
  }

  if (lower.includes("signup requires a valid password")) {
    return "Vui lòng nhập mật khẩu hợp lệ.";
  }

  return rawMessage || "Đã xảy ra lỗi trong quá trình xác thực.";
}
