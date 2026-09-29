/** Anything with supabase-js's `from()` — the real client or a test fake. */
export type DbClient = { from: (table: string) => any };

export const RATE_LIMIT_PER_HOUR = 100;
export const MAX_WORD_LENGTH = 64;
export const MAX_TEXT_LENGTH = 1000;

// Gemini ids are interpolated into the API URL path, so keep them to a safe charset.
const GEMINI_MODEL = /^gemini-[a-z0-9.\-]+$/;
// Only free OpenRouter models: paid ones would bill our key.
const OPENROUTER_FREE_MODEL = /^[\w.\-]+\/[\w.\-]+:free$/;

/** The client's model if allowed for this provider, else undefined (= use default). */
export function sanitizeModel(provider: string, model: unknown): string | undefined {
  if (typeof model !== "string") return undefined;
  const pattern = provider === "gemini" ? GEMINI_MODEL : OPENROUTER_FREE_MODEL;
  return pattern.test(model) ? model : undefined;
}

/** True once the user made RATE_LIMIT_PER_HOUR AI calls in the last hour. Fails open. */
export async function isRateLimited(userId: string, client: DbClient): Promise<boolean> {
  try {
    const oneHourAgo = new Date(Date.now() - 60 * 60 * 1000).toISOString();
    const { count, error } = await client
      .from("api_usage_logs")
      .select("id", { count: "exact", head: true })
      .eq("user_id", userId)
      .gte("created_at", oneHourAgo)
      // Rejected calls don't count, so a user recovers once they stop hammering.
      .neq("status", "rate_limited");
    if (error) throw error;
    return (count ?? 0) >= RATE_LIMIT_PER_HOUR;
  } catch (err) {
    console.warn("[ai-guard] rate limit check failed, allowing request:", err);
    return false;
  }
}
