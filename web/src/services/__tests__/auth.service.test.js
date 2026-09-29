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

vi.mock("../../db/sync", () => ({
  syncEngine: {
    pushChanges: vi.fn().mockResolvedValue({ pushed: 0, errors: [] }),
    unsyncedCount: vi.fn().mockResolvedValue(0),
  },
}));

import "fake-indexeddb/auto";
import { authService } from "../auth.service";
import { supabase } from "../../config/supabase";
import { syncEngine } from "../../db/sync";
import db from "../../db/database";

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

  it("signOut pushes first and clears local data and sync markers", async () => {
    supabase.auth.signOut.mockResolvedValue({ error: null });
    await db.vocabularies.put({ id: "v1", user_id: "u1", word: "left behind" });
    await db.sync_queue.add({ table_name: "vocabularies", synced: true });
    localStorage.setItem("last_sync_u1", "2026-09-28T00:00:00Z");

    const result = await authService.signOut();

    expect(result).toEqual({ unsynced: 0 });
    expect(syncEngine.pushChanges).toHaveBeenCalled();
    expect(await db.vocabularies.count()).toBe(0);
    expect(await db.sync_queue.count()).toBe(0);
    expect(localStorage.getItem("last_sync_u1")).toBeNull();
  });

  it("signOut stops and reports unsynced changes unless told to discard them", async () => {
    supabase.auth.signOut.mockClear();
    syncEngine.unsyncedCount.mockResolvedValueOnce(3);
    await db.vocabularies.put({ id: "v2", user_id: "u1", word: "keep me" });

    expect(await authService.signOut()).toEqual({ unsynced: 3 });
    expect(supabase.auth.signOut).not.toHaveBeenCalled();
    expect(await db.vocabularies.count()).toBe(1);

    syncEngine.unsyncedCount.mockResolvedValueOnce(3);
    supabase.auth.signOut.mockResolvedValue({ error: null });
    await authService.signOut({ discardUnsynced: true });
    expect(supabase.auth.signOut).toHaveBeenCalled();
    expect(await db.vocabularies.count()).toBe(0);
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
