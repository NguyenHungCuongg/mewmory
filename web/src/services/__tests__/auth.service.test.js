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
    },
  },
}));

import { authService } from "../auth.service";
import { supabase } from "../../config/supabase";

describe("authService", () => {
  it("signUp calls supabase.auth.signUp", async () => {
    supabase.auth.signUp.mockResolvedValue({
      data: { user: { id: "1" } },
      error: null,
    });
    const result = await authService.signUp("test@example.com", "password");
    expect(result.user).toBeDefined();
    expect(result.error).toBeNull();
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
});
