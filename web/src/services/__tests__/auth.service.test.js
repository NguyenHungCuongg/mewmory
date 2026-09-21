import { describe, it, expect, vi } from "vitest";

// Mock supabase
vi.mock("../../config/supabase", () => ({
  supabase: {
    auth: {
      signUp: vi.fn(),
      signInWithPassword: vi.fn(),
      signInWithOAuth: vi.fn(),
      signOut: vi.fn(),
      getSession: vi.fn(),
      onAuthStateChange: vi.fn(),
      updateUser: vi.fn(),
    },
    from: vi.fn(() => ({
      update: vi.fn(() => ({
        eq: vi.fn(() => Promise.resolve({ error: null })),
      })),
    })),
  },
}));

import { authService } from "../auth.service";
import { supabase } from "../../config/supabase";

describe("authService", () => {
  it("signUp passes displayName to options.data when provided", async () => {
    supabase.auth.signUp.mockResolvedValue({
      data: {
        user: { id: "1", email: "test@example.com", identities: [{ id: "ident-1" }] },
        session: { access_token: "token-123" },
      },
      error: null,
    });
    const result = await authService.signUp("test@example.com", "password", {
      displayName: "Cường",
    });
    expect(result.user).toBeDefined();
    expect(supabase.auth.signUp).toHaveBeenCalledWith({
      email: "test@example.com",
      password: "password",
      options: {
        data: {
          full_name: "Cường",
          display_name: "Cường",
        },
      },
    });
  });

  it("signUp returns user and session when sign up succeeds for new user", async () => {
    supabase.auth.signUp.mockResolvedValue({
      data: {
        user: { id: "1", email: "test@example.com", identities: [{ id: "ident-1" }] },
        session: { access_token: "token-123" },
      },
      error: null,
    });
    const result = await authService.signUp("test@example.com", "password");
    expect(result.user).toBeDefined();
    expect(result.session).toBeDefined();
    expect(result.error).toBeNull();
  });

  it("signUp returns error when user already exists (empty identities array from Supabase)", async () => {
    supabase.auth.signUp.mockResolvedValue({
      data: {
        user: { id: "1", email: "existing@example.com", identities: [] },
        session: null,
      },
      error: null,
    });
    const result = await authService.signUp("existing@example.com", "password");
    expect(result.error).toBeDefined();
    expect(result.error.code).toBe("user_already_exists");
    expect(result.error.message).toContain("Email này đã được đăng ký");
    expect(result.user).toBeNull();
  });

  it("signUp returns error when supabase returns error", async () => {
    supabase.auth.signUp.mockResolvedValue({
      data: { user: null, session: null },
      error: { message: "Password is too weak" },
    });
    const result = await authService.signUp("test@example.com", "weak");
    expect(result.error).toBeDefined();
    expect(result.error.message).toBe("Password is too weak");
  });

  it("signIn calls supabase.auth.signInWithPassword", async () => {
    supabase.auth.signInWithPassword.mockResolvedValue({
      data: { user: { id: "1" }, session: { access_token: "token" } },
      error: null,
    });
    const result = await authService.signIn("test@example.com", "password");
    expect(result.user).toBeDefined();
    expect(result.session).toBeDefined();
  });

  it("signOut calls supabase.auth.signOut", async () => {
    supabase.auth.signOut.mockResolvedValue({ error: null });
    await authService.signOut();
    expect(supabase.auth.signOut).toHaveBeenCalled();
  });

  it("updateDisplayName updates auth user and profile table", async () => {
    supabase.auth.updateUser.mockResolvedValue({
      data: { user: { id: "user-1", email: "test@example.com" } },
      error: null,
    });
    const result = await authService.updateDisplayName("Cường");
    expect(result.user).toBeDefined();
    expect(supabase.auth.updateUser).toHaveBeenCalledWith({
      data: {
        display_name: "Cường",
        full_name: "Cường",
      },
    });
  });

  it("updateDisplayName rejects empty name with error", async () => {
    const result = await authService.updateDisplayName("   ");
    expect(result.error).toBeDefined();
    expect(result.error.message).toContain("không được để trống");
  });
});
