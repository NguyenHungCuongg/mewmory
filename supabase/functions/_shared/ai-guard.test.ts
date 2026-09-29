import { assertEquals } from "jsr:@std/assert@1";
import { isRateLimited, RATE_LIMIT_PER_HOUR, sanitizeModel } from "./ai-guard.ts";

Deno.test("sanitizeModel keeps gemini-* names for gemini", () => {
  assertEquals(sanitizeModel("gemini", "gemini-3.6-flash"), "gemini-3.6-flash");
  assertEquals(sanitizeModel("gemini", "gemini-3.5-flash-lite"), "gemini-3.5-flash-lite");
});

Deno.test("sanitizeModel keeps only :free models for openrouter", () => {
  assertEquals(
    sanitizeModel("openrouter", "google/gemma-4-31b-it:free"),
    "google/gemma-4-31b-it:free",
  );
  assertEquals(sanitizeModel("openrouter", "openai/gpt-5"), undefined);
  assertEquals(sanitizeModel("openrouter", "anthropic/claude-opus:free-trial"), undefined);
});

Deno.test("sanitizeModel rejects mismatched, malformed or missing models", () => {
  assertEquals(sanitizeModel("gemini", "google/gemma-4-31b-it:free"), undefined);
  assertEquals(sanitizeModel("gemini", "gemini-3.6-flash:generateContent?x=1"), undefined);
  assertEquals(sanitizeModel("gemini", "../models/secret"), undefined);
  assertEquals(sanitizeModel("gemini", undefined), undefined);
  assertEquals(sanitizeModel("gemini", 42), undefined);
  assertEquals(sanitizeModel("gemini", ""), undefined);
});

// from(t).select(c, opts).eq(k, v).gte(k, v).neq(k, v) -> Promise<{ count, error }>
function fakeLogs(count: number | null, opts: { error?: unknown; throws?: boolean } = {}) {
  const calls: unknown[][] = [];
  const client = {
    from(table: string) {
      if (opts.throws) throw new Error("connection refused");
      calls.push(["from", table]);
      const builder = {
        select: (...a: unknown[]) => (calls.push(["select", ...a]), builder),
        eq: (...a: unknown[]) => (calls.push(["eq", ...a]), builder),
        gte: (...a: unknown[]) => (calls.push(["gte", ...a]), builder),
        neq: (...a: unknown[]) => {
          calls.push(["neq", ...a]);
          return Promise.resolve({ count, error: opts.error ?? null });
        },
      };
      return builder;
    },
  };
  return { client, calls };
}

Deno.test("isRateLimited is true at the hourly limit and false below it", async () => {
  assertEquals(await isRateLimited("u1", fakeLogs(RATE_LIMIT_PER_HOUR - 1).client), false);
  assertEquals(await isRateLimited("u1", fakeLogs(RATE_LIMIT_PER_HOUR).client), true);
});

Deno.test("isRateLimited counts this user's last hour, excluding rate_limited rows", async () => {
  const { client, calls } = fakeLogs(0);
  await isRateLimited("u1", client);
  assertEquals(calls[0], ["from", "api_usage_logs"]);
  assertEquals(calls[2], ["eq", "user_id", "u1"]);
  assertEquals(calls[3][0], "gte");
  assertEquals(calls[4], ["neq", "status", "rate_limited"]);
});

Deno.test("isRateLimited fails open on query errors", async () => {
  assertEquals(await isRateLimited("u1", fakeLogs(null, { error: { message: "x" } }).client), false);
  assertEquals(await isRateLimited("u1", fakeLogs(null, { throws: true }).client), false);
});
