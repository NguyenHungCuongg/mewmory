import { describe, it, expect } from "vitest";
import { getAuthErrorMessage } from "../authErrors";

describe("getAuthErrorMessage", () => {
  it("translates user already registered errors", () => {
    expect(
      getAuthErrorMessage({ message: "User already registered" })
    ).toBe("Email này đã được đăng ký. Vui lòng đăng nhập bằng mật khẩu của bạn.");

    expect(
      getAuthErrorMessage({ code: "user_already_exists" })
    ).toBe("Email này đã được đăng ký. Vui lòng đăng nhập bằng mật khẩu của bạn.");
  });

  it("translates invalid login credentials", () => {
    expect(
      getAuthErrorMessage({ message: "Invalid login credentials" })
    ).toBe("Email hoặc mật khẩu không chính xác.");
  });

  it("translates unconfirmed email", () => {
    expect(
      getAuthErrorMessage({ message: "Email not confirmed" })
    ).toBe("Email chưa được xác nhận. Vui lòng kiểm tra hộp thư để kích hoạt tài khoản.");
  });

  it("translates short password", () => {
    expect(
      getAuthErrorMessage({
        message: "Password should be at least 6 characters",
      })
    ).toBe("Mật khẩu phải có ít nhất 6 ký tự.");
  });

  it("translates rate limit errors", () => {
    expect(
      getAuthErrorMessage({ message: "Rate limit exceeded" })
    ).toBe("Quá nhiều yêu cầu. Vui lòng thử lại sau giây lát.");

    expect(
      getAuthErrorMessage({ message: "over_email_send_rate_limit: email rate limit exceeded" })
    ).toBe("Quá nhiều yêu cầu. Vui lòng thử lại sau giây lát.");
  });

  it("translates database error saving new user", () => {
    expect(
      getAuthErrorMessage({ message: "Database error saving new user" })
    ).toBe("Lỗi cơ sở dữ liệu khi tạo tài khoản. Vui lòng thử lại sau.");
  });

  it("falls back to raw message for unhandled errors", () => {
    expect(
      getAuthErrorMessage({ message: "Custom server error" })
    ).toBe("Custom server error");
  });
});
