export function validateWord(word) {
  if (!word || typeof word !== "string") {
    return { valid: false, error: "Vui lòng nhập từ vựng" };
  }
  const trimmed = word.trim();
  if (trimmed.length === 0) {
    return { valid: false, error: "Vui lòng nhập từ vựng" };
  }
  if (trimmed.length > 100) {
    return { valid: false, error: "Từ vựng quá dài (tối đa 100 ký tự)" };
  }
  if (!/^[a-zA-Z\s'-]+$/.test(trimmed)) {
    return { valid: false, error: "Từ vựng chỉ chứa chữ cái tiếng Anh" };
  }
  return { valid: true };
}

export function validateEmail(email) {
  if (!email || typeof email !== "string") {
    return { valid: false, error: "Vui lòng nhập email" };
  }
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailRegex.test(email.trim())) {
    return { valid: false, error: "Email không hợp lệ" };
  }
  return { valid: true };
}

export function validatePassword(password) {
  if (!password || typeof password !== "string") {
    return { valid: false, error: "Vui lòng nhập mật khẩu" };
  }
  if (password.length < 6) {
    return { valid: false, error: "Mật khẩu phải có ít nhất 6 ký tự" };
  }
  return { valid: true };
}
