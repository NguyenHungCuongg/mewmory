import { supabase } from "../config/supabase";
import db from "../db/database";
import { syncEngine } from "../db/sync";

export const authService = {
  async signUp(email, password, options = {}) {
    const displayName = options?.displayName?.trim();
    const signUpOptions = displayName
      ? { data: { full_name: displayName, display_name: displayName } }
      : undefined;

    const { data, error } = await supabase.auth.signUp({
      email,
      password,
      options: signUpOptions,
    });

    if (error) {
      return { user: null, session: null, error };
    }

    // Supabase returns an empty identities array if the user already exists (User Enumeration Protection)
    if (
      data?.user &&
      Array.isArray(data.user.identities) &&
      data.user.identities.length === 0
    ) {
      return {
        user: null,
        session: null,
        error: {
          message:
            "Email này đã được đăng ký. Vui lòng đăng nhập bằng mật khẩu của bạn.",
          code: "user_already_exists",
        },
      };
    }

    return { user: data?.user, session: data?.session, error: null };
  },

  async updateDisplayName(displayName) {
    const trimmed = displayName?.trim();
    if (!trimmed) {
      return { error: { message: "Tên hiển thị không được để trống." } };
    }

    const { data, error } = await supabase.auth.updateUser({
      data: {
        display_name: trimmed,
        full_name: trimmed,
      },
    });

    if (error) {
      return { user: null, error };
    }

    try {
      if (data?.user?.id) {
        await supabase
          .from("profiles")
          .update({
            display_name: trimmed,
            updated_at: new Date().toISOString(),
          })
          .eq("id", data.user.id);
      }
    } catch (_) {}

    return { user: data?.user, error: null };
  },

  async signIn(email, password) {
    const { data, error } = await supabase.auth.signInWithPassword({
      email,
      password,
    });
    return { user: data?.user, session: data?.session, error };
  },

  async signInWithGoogle() {
    const { data, error } = await supabase.auth.signInWithOAuth({
      provider: "google",
      options: {
        redirectTo: window.location.origin,
      },
    });
    return { data, error };
  },

  /**
   * Pushes pending changes, then signs out and wipes local data so the next
   * user of this browser can't see it. If changes still can't be pushed,
   * returns `{ unsynced }` without signing out unless `discardUnsynced`.
   */
  async signOut({ discardUnsynced = false } = {}) {
    if (navigator.onLine) {
      try {
        await syncEngine.pushChanges();
      } catch (err) {
        console.error("Push before sign out failed:", err);
      }
    }

    const unsynced = await syncEngine.unsyncedCount();
    if (unsynced > 0 && !discardUnsynced) return { unsynced };

    const { error } = await supabase.auth.signOut();
    if (error) throw error;

    await Promise.all(db.tables.map((table) => table.clear()));
    Object.keys(localStorage)
      .filter((key) => key.startsWith("last_sync_"))
      .forEach((key) => localStorage.removeItem(key));
    return { unsynced: 0 };
  },

  async getSession() {
    const { data, error } = await supabase.auth.getSession();
    return { session: data?.session, error };
  },

  onAuthStateChange(callback) {
    return supabase.auth.onAuthStateChange(callback);
  },
};
