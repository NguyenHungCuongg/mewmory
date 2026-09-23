import { supabase } from "../config/supabase";

const EDGE_FUNCTION_URL = `${import.meta.env.VITE_SUPABASE_URL}/functions/v1/admin-api`;

async function callAdminApi(action, options = {}) {
  const { data: { session } } = await supabase.auth.getSession();
  if (!session) throw new Error("Not authenticated");

  const { method = "GET", body, params = {} } = options;

  const url = new URL(EDGE_FUNCTION_URL);
  url.searchParams.set("action", action);
  for (const [key, value] of Object.entries(params)) {
    url.searchParams.set(key, value);
  }

  const res = await fetch(url.toString(), {
    method,
    headers: {
      Authorization: `Bearer ${session.access_token}`,
      "Content-Type": "application/json",
    },
    body: body ? JSON.stringify(body) : undefined,
  });

  if (!res.ok) {
    const err = await res.json().catch(() => ({ error: res.statusText }));
    throw new Error(err.error || `HTTP ${res.status}`);
  }

  return res.json();
}

export const adminService = {
  getSystemStats: () => callAdminApi("system_stats"),

  listUsers: () => callAdminApi("list_users"),

  getUserDetail: (userId) =>
    callAdminApi("user_detail", { params: { user_id: userId } }),

  banUser: (userId, reason) =>
    callAdminApi("ban_user", {
      method: "POST",
      body: { user_id: userId, reason },
    }),

  unbanUser: (userId) =>
    callAdminApi("unban_user", { method: "POST", body: { user_id: userId } }),

  unflagUser: (userId) =>
    callAdminApi("unflag_user", { method: "POST", body: { user_id: userId } }),
};
