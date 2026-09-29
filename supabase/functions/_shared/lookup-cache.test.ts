import { assertEquals } from "jsr:@std/assert@1";
import {
  CACHE_TTL_DAYS,
  getCachedLookup,
  isCacheable,
  isFresh,
  normalizeWord,
  putCachedLookup,
} from "./lookup-cache.ts";

// Minimal stand-in for the supabase-js query builder chains we use:
//   from(t).select(c).eq(k, v).maybeSingle()   and   from(t).upsert(row)
function fakeClient(
  row: unknown,
  opts: { error?: unknown; throws?: boolean } = {},
) {
  const calls: unknown[][] = [];
  const client = {
    from(table: string) {
      if (opts.throws) throw new Error("connection refused");
      const builder = {
        select(cols: string) {
          calls.push(["select", table, cols]);
          return builder;
        },
        eq(col: string, val: string) {
          calls.push(["eq", col, val]);
          return builder;
        },
        maybeSingle() {
          return Promise.resolve({ data: row, error: opts.error ?? null });
        },
        upsert(payload: unknown) {
          calls.push(["upsert", table, payload]);
          return Promise.resolve({ error: opts.error ?? null });
        },
      };
      return builder;
    },
  };
  return { client, calls };
}

const complete = {
  word: "run",
  meanings: [{ part_of_speech: "verb", definitions: [] }],
  source: { dictionary: true, ai: true },
};

Deno.test("normalizeWord trims, lowercases and collapses inner spaces", () => {
  assertEquals(normalizeWord("  Run "), "run");
  assertEquals(normalizeWord("RUN"), "run");
  assertEquals(normalizeWord("ice   cream"), "ice cream");
});

Deno.test("isFresh is true inside TTL and false at/after it", () => {
  const now = new Date("2026-09-28T00:00:00Z");
  const day = 86_400_000;
  const at = (daysAgo: number) =>
    new Date(now.getTime() - daysAgo * day).toISOString();
  assertEquals(isFresh(at(1), now), true);
  assertEquals(isFresh(at(CACHE_TTL_DAYS - 0.01), now), true);
  assertEquals(isFresh(at(CACHE_TTL_DAYS), now), false);
  assertEquals(isFresh(at(45), now), false);
});

Deno.test("isCacheable only accepts complete results with meanings", () => {
  assertEquals(isCacheable(complete), true);
  assertEquals(isCacheable({ ...complete, source: { dictionary: true, ai: false } }), false);
  assertEquals(isCacheable({ ...complete, source: { dictionary: false, ai: true } }), false);
  assertEquals(isCacheable({ ...complete, meanings: [] }), false);
  assertEquals(isCacheable(null), false);
});

Deno.test("getCachedLookup returns the stored result when fresh", async () => {
  const now = new Date("2026-09-28T00:00:00Z");
  const { client, calls } = fakeClient({
    result: complete,
    created_at: "2026-09-27T00:00:00Z",
  });
  assertEquals(await getCachedLookup(client, "run", now), complete);
  assertEquals(calls, [
    ["select", "lookup_cache", "result, created_at"],
    ["eq", "word", "run"],
  ]);
});

Deno.test("getCachedLookup returns null when stale", async () => {
  const now = new Date("2026-09-28T00:00:00Z");
  const { client } = fakeClient({
    result: complete,
    created_at: "2026-07-01T00:00:00Z",
  });
  assertEquals(await getCachedLookup(client, "run", now), null);
});

Deno.test("getCachedLookup returns null on miss, query error, or thrown error", async () => {
  assertEquals(await getCachedLookup(fakeClient(null).client, "run"), null);
  assertEquals(
    await getCachedLookup(fakeClient(null, { error: { message: "boom" } }).client, "run"),
    null,
  );
  assertEquals(await getCachedLookup(fakeClient(null, { throws: true }).client, "run"), null);
});

Deno.test("putCachedLookup upserts word, result and created_at", async () => {
  const { client, calls } = fakeClient(null);
  await putCachedLookup(client, "run", complete);
  const [op, table, payload] = calls[0] as [string, string, Record<string, unknown>];
  assertEquals(op, "upsert");
  assertEquals(table, "lookup_cache");
  assertEquals(payload.word, "run");
  assertEquals(payload.result, complete);
  assertEquals(typeof payload.created_at, "string");
});

Deno.test("putCachedLookup never throws", async () => {
  await putCachedLookup(fakeClient(null, { error: { message: "boom" } }).client, "run", complete);
  await putCachedLookup(fakeClient(null, { throws: true }).client, "run", complete);
});
