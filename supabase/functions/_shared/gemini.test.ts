import { assertEquals, assertRejects } from "jsr:@std/assert@1";
import { GEMINI_FALLBACK_MODELS, geminiGenerate } from "./gemini.ts";

// Fake fetch: answers per model id (parsed from the URL), records the order tried.
function fakeFetch(answers: Record<string, number | string>) {
  const tried: string[] = [];
  const fetchFn = (url: string) => {
    const model = url.match(/models\/([^:]+):/)![1];
    tried.push(model);
    const a = answers[model] ?? 503;
    if (typeof a === "number") {
      return Promise.resolve(new Response("overloaded", { status: a }));
    }
    const body = { candidates: [{ content: { parts: [{ text: a }] } }] };
    return Promise.resolve(new Response(JSON.stringify(body)));
  };
  return { fetchFn, tried };
}

const raw = (s: string) => s || null;

Deno.test("geminiGenerate returns the requested model's answer", async () => {
  const { fetchFn, tried } = fakeFetch({ "gemini-x-flash": "ok" });
  assertEquals(await geminiGenerate("k", "p", "gemini-x-flash", raw, fetchFn), "ok");
  assertEquals(tried, ["gemini-x-flash"]);
});

Deno.test("geminiGenerate falls back to the next model on 503", async () => {
  const [first, second] = GEMINI_FALLBACK_MODELS;
  const { fetchFn, tried } = fakeFetch({ [first]: 503, [second]: "ok" });
  assertEquals(await geminiGenerate("k", "p", undefined, raw, fetchFn), "ok");
  assertEquals(tried, [first, second]);
});

Deno.test("geminiGenerate falls back when the answer does not parse", async () => {
  const [first, second] = GEMINI_FALLBACK_MODELS;
  const { fetchFn, tried } = fakeFetch({ [first]: "", [second]: "ok" });
  assertEquals(await geminiGenerate("k", "p", first, raw, fetchFn), "ok");
  assertEquals(tried, [first, second]);
});

Deno.test("geminiGenerate tries each model once, then throws the last error", async () => {
  const { fetchFn, tried } = fakeFetch({});
  await assertRejects(
    () => geminiGenerate("k", "p", GEMINI_FALLBACK_MODELS[1], raw, fetchFn),
    Error,
    "503",
  );
  assertEquals(tried.length, GEMINI_FALLBACK_MODELS.length);
  assertEquals(new Set(tried).size, tried.length);
});
