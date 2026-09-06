import { describe, it, expect, vi, beforeEach } from "vitest";
import { render, screen, fireEvent, waitFor } from "@testing-library/react";
import { BrowserRouter } from "react-router-dom";
import LoginPage from "../LoginPage";
import { authService } from "../../services/auth.service";
import { useUIStore } from "../../stores/ui.store";

const mockNavigate = vi.fn();
vi.mock("react-router-dom", async () => {
  const actual = await vi.importActual("react-router-dom");
  return {
    ...actual,
    useNavigate: () => mockNavigate,
  };
});

vi.mock("../../services/auth.service", () => ({
  authService: {
    signUp: vi.fn(),
    signIn: vi.fn(),
    signInWithGoogle: vi.fn(),
  },
}));

describe("LoginPage", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    useUIStore.setState({ toasts: [] });
  });

  const renderComponent = () =>
    render(
      <BrowserRouter>
        <LoginPage />
      </BrowserRouter>,
    );

  it("renders login form by default", () => {
    renderComponent();
    expect(screen.getByRole("heading", { name: "Đăng nhập" })).toBeInTheDocument();
    expect(screen.getByRole("button", { name: "Đăng nhập" })).toBeInTheDocument();
  });

  it("can toggle between login and sign up modes and show/hide confirm password", () => {
    renderComponent();
    expect(screen.queryByLabelText("Nhập lại mật khẩu")).not.toBeInTheDocument();

    const toggleBtn = screen.getByRole("button", { name: "Đăng ký" });
    fireEvent.click(toggleBtn);

    expect(screen.getByRole("heading", { name: "Tạo tài khoản" })).toBeInTheDocument();
    expect(screen.getByRole("button", { name: "Tạo tài khoản" })).toBeInTheDocument();
    expect(screen.getByLabelText("Nhập lại mật khẩu")).toBeInTheDocument();

    // Toggle back
    fireEvent.click(screen.getByRole("button", { name: "Đăng nhập" }));
    expect(screen.queryByLabelText("Nhập lại mật khẩu")).not.toBeInTheDocument();
  });

  it("validates confirm password on sign up", async () => {
    renderComponent();
    fireEvent.click(screen.getByRole("button", { name: "Đăng ký" }));

    fireEvent.change(screen.getByLabelText("Email"), {
      target: { value: "test@example.com" },
    });
    fireEvent.change(screen.getByLabelText("Mật khẩu"), {
      target: { value: "password123" },
    });

    // Submit with empty confirm password
    fireEvent.click(screen.getByRole("button", { name: "Tạo tài khoản" }));
    expect(screen.getByText("Vui lòng nhập lại mật khẩu")).toBeInTheDocument();
    expect(authService.signUp).not.toHaveBeenCalled();

    // Submit with non-matching confirm password
    fireEvent.change(screen.getByLabelText("Nhập lại mật khẩu"), {
      target: { value: "different123" },
    });
    fireEvent.click(screen.getByRole("button", { name: "Tạo tài khoản" }));
    expect(screen.getByText("Mật khẩu xác nhận không khớp")).toBeInTheDocument();
    expect(authService.signUp).not.toHaveBeenCalled();
  });

  it("shows error and switches to login mode when signing up with an already registered email", async () => {
    authService.signUp.mockResolvedValue({
      user: null,
      session: null,
      error: {
        message: "Email này đã được đăng ký. Vui lòng đăng nhập bằng mật khẩu của bạn.",
        code: "user_already_exists",
      },
    });

    renderComponent();
    // Switch to signup
    fireEvent.click(screen.getByRole("button", { name: "Đăng ký" }));

    // Fill form
    fireEvent.change(screen.getByLabelText("Email"), {
      target: { value: "existing@example.com" },
    });
    fireEvent.change(screen.getByLabelText("Mật khẩu"), {
      target: { value: "newpassword123" },
    });
    fireEvent.change(screen.getByLabelText("Nhập lại mật khẩu"), {
      target: { value: "newpassword123" },
    });

    fireEvent.click(screen.getByRole("button", { name: "Tạo tài khoản" }));

    await waitFor(() => {
      expect(authService.signUp).toHaveBeenCalledWith(
        "existing@example.com",
        "newpassword123",
      );
    });

    await waitFor(() => {
      const toasts = useUIStore.getState().toasts;
      expect(toasts.length).toBe(1);
      expect(toasts[0].type).toBe("error");
      expect(toasts[0].message).toContain("Email này đã được đăng ký");
    });

    // Should NOT navigate to "/"
    expect(mockNavigate).not.toHaveBeenCalled();

    // Should switch back to login mode so user can log in with existing password
    expect(screen.getByRole("heading", { name: "Đăng nhập" })).toBeInTheDocument();
  });

  it("shows info toast and switches to login when signing up requires email confirmation (session is null)", async () => {
    authService.signUp.mockResolvedValue({
      user: { id: "new-user-id" },
      session: null,
      error: null,
    });

    renderComponent();
    fireEvent.click(screen.getByRole("button", { name: "Đăng ký" }));

    fireEvent.change(screen.getByLabelText("Email"), {
      target: { value: "newuser@example.com" },
    });
    fireEvent.change(screen.getByLabelText("Mật khẩu"), {
      target: { value: "password123" },
    });
    fireEvent.change(screen.getByLabelText("Nhập lại mật khẩu"), {
      target: { value: "password123" },
    });

    fireEvent.click(screen.getByRole("button", { name: "Tạo tài khoản" }));

    await waitFor(() => {
      const toasts = useUIStore.getState().toasts;
      expect(toasts.length).toBe(1);
      expect(toasts[0].type).toBe("info");
      expect(toasts[0].message).toContain("kiểm tra email để kích hoạt tài khoản");
    });

    expect(mockNavigate).not.toHaveBeenCalled();
    expect(screen.getByRole("heading", { name: "Đăng nhập" })).toBeInTheDocument();
  });

  it("navigates to / when sign up returns an active session", async () => {
    authService.signUp.mockResolvedValue({
      user: { id: "new-user-id" },
      session: { access_token: "token" },
      error: null,
    });

    renderComponent();
    fireEvent.click(screen.getByRole("button", { name: "Đăng ký" }));

    fireEvent.change(screen.getByLabelText("Email"), {
      target: { value: "newuser@example.com" },
    });
    fireEvent.change(screen.getByLabelText("Mật khẩu"), {
      target: { value: "password123" },
    });
    fireEvent.change(screen.getByLabelText("Nhập lại mật khẩu"), {
      target: { value: "password123" },
    });

    fireEvent.click(screen.getByRole("button", { name: "Tạo tài khoản" }));

    await waitFor(() => {
      expect(mockNavigate).toHaveBeenCalledWith("/");
      const toasts = useUIStore.getState().toasts;
      expect(toasts.length).toBe(1);
      expect(toasts[0].type).toBe("success");
    });
  });

  it("shows translated error when login fails with invalid credentials", async () => {
    authService.signIn.mockResolvedValue({
      user: null,
      session: null,
      error: { message: "Invalid login credentials" },
    });

    renderComponent();
    fireEvent.change(screen.getByLabelText("Email"), {
      target: { value: "user@example.com" },
    });
    fireEvent.change(screen.getByLabelText("Mật khẩu"), {
      target: { value: "wrongpassword" },
    });

    fireEvent.click(screen.getByRole("button", { name: "Đăng nhập" }));

    await waitFor(() => {
      const toasts = useUIStore.getState().toasts;
      expect(toasts.length).toBe(1);
      expect(toasts[0].type).toBe("error");
      expect(toasts[0].message).toBe("Email hoặc mật khẩu không chính xác.");
    });

    expect(mockNavigate).not.toHaveBeenCalled();
  });
});
