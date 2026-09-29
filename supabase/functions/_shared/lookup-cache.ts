/** Anything with supabase-js's `from()` — the real client or a test fake. */
export type DbClient = { from: (table: string) => any };

export const CACHE_TTL_DAYS = 30;
const DAY_MS = 86_400_000;

/** Cache key: "  Ice   Cream " -> "ice cream". */
export function normalizeWord(word: string): string {
  return word.trim().toLowerCase().replace(/\s+/g, " ");
}

export function isFresh(
  createdAt: string,
  now: Date,
  ttlDays = CACHE_TTL_DAYS,
): boolean {
  return now.getTime() - new Date(createdAt).getTime() < ttlDays * DAY_MS;
}

/**
 * Cache once AI answered properly. Dictionary is optional: it's too slow/unreliable
 * to gate on, and requiring it meant nothing was ever cached.
 */
export function isCacheable(result: any): boolean {
  return (
    !!result?.source?.ai &&
    Array.isArray(result.meanings) &&
    result.meanings.length > 0 &&
    // AI can "succeed" with `{}`; cefr_level proves it actually answered.
    !!result.meanings[0].cefr_level
  );
}

/** Fresh cached result for `word`, or null. Never throws. */
export async function getCachedLookup(
  client: DbClient,
  word: string,
  now = new Date(),
): Promise<any | null> {
  try {
    const { data, error } = await client
      .from("lookup_cache")
      .select("result, created_at")
      .eq("word", word)
      .maybeSingle();
    if (error || !data || !isFresh(data.created_at, now)) return null;
    return data.result;
  } catch (err) {
    console.warn("[lookup-cache] read failed:", err);
    return null;
  }
}

/** Insert or refresh the cache row. Never throws. */
export async function putCachedLookup(
  client: DbClient,
  word: string,
  result: any,
): Promise<void> {
  try {
    const { error } = await client.from("lookup_cache").upsert({
      word,
      result,
      created_at: new Date().toISOString(),
    });
    if (error) console.warn("[lookup-cache] write failed:", error);
  } catch (err) {
    console.warn("[lookup-cache] write failed:", err);
  }
}
