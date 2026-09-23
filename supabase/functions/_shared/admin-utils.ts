import { createClient, SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2";

/** Extract user_id from a Supabase JWT Authorization header. Returns null if invalid. */
export async function getUserIdFromJWT(
  authHeader: string,
  supabaseUrl: string,
  supabaseAnonKey: string
): Promise<string | null> {
  try {
    const client = createClient(supabaseUrl, supabaseAnonKey);
    const token = authHeader.replace("Bearer ", "");
    const { data: { user }, error } = await client.auth.getUser(token);
    if (error || !user) return null;
    return user.id;
  } catch {
    return null;
  }
}

/**
 * Check if user is banned.
 * Uses service-role client (adminClient) to bypass RLS.
 * Returns true if banned.
 */
export async function checkBanned(
  userId: string,
  adminClient: SupabaseClient
): Promise<boolean> {
  const { data } = await adminClient
    .from("profiles")
    .select("is_banned")
    .eq("id", userId)
    .single();
  return data?.is_banned === true;
}

/**
 * Insert one row into api_usage_logs.
 * Uses service-role client (adminClient).
 * Silently swallows errors — logging must never break the main request.
 */
export async function logUsage(
  userId: string,
  action: "lookup_word" | "ai_classify" | "translate_definition",
  word: string | null,
  status: "success" | "error" | "rate_limited" | "banned",
  adminClient: SupabaseClient
): Promise<void> {
  try {
    await adminClient.from("api_usage_logs").insert({
      user_id: userId,
      action,
      word: word ?? null,
      status,
    });
  } catch (err) {
    console.warn("[admin-utils] logUsage failed silently:", err);
  }
}

/**
 * Update profiles.last_active_at = NOW() for the user.
 * Silently swallows errors.
 */
export async function updateLastActive(
  userId: string,
  adminClient: SupabaseClient
): Promise<void> {
  try {
    await adminClient
      .from("profiles")
      .update({ last_active_at: new Date().toISOString() })
      .eq("id", userId);
  } catch (err) {
    console.warn("[admin-utils] updateLastActive failed silently:", err);
  }
}

/**
 * Count calls by this user in the last 1 hour.
 * If count > 50, set is_flagged = true on profiles.
 * Silently swallows errors.
 */
export async function checkAndFlagSpam(
  userId: string,
  adminClient: SupabaseClient
): Promise<void> {
  try {
    const oneHourAgo = new Date(Date.now() - 60 * 60 * 1000).toISOString();
    const { count } = await adminClient
      .from("api_usage_logs")
      .select("id", { count: "exact", head: true })
      .eq("user_id", userId)
      .gte("created_at", oneHourAgo);

    if (count !== null && count > 50) {
      await adminClient
        .from("profiles")
        .update({ is_flagged: true })
        .eq("id", userId)
        .eq("is_flagged", false); // only update if not already flagged
    }
  } catch (err) {
    console.warn("[admin-utils] checkAndFlagSpam failed silently:", err);
  }
}

/** Create a service-role Supabase client. Call once per Edge Function invocation. */
export function createAdminClient(): SupabaseClient {
  const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
  return createClient(supabaseUrl, serviceRoleKey, {
    auth: { persistSession: false },
  });
}
