// Free-tier Gemini models, tried in order after the requested one.
export const GEMINI_FALLBACK_MODELS = [
  "gemini-3.5-flash-lite",
  "gemini-3.1-flash-lite",
  "gemini-3.6-flash",
];

/**
 * Calls Gemini with `model` (default: first fallback), moving to the next
 * fallback model on any failure (503 overload, 429, 404, timeout, or an
 * answer `parse` rejects with null / a throw). Throws the last error.
 */
export async function geminiGenerate<T>(
  apiKey: string,
  prompt: string,
  model: string | undefined,
  parse: (raw: string) => T | null,
  fetchFn: (url: string, init?: RequestInit) => Promise<Response> = fetch,
): Promise<T> {
  const candidates = [...new Set([model ?? GEMINI_FALLBACK_MODELS[0], ...GEMINI_FALLBACK_MODELS])];

  let lastError: unknown = null;
  for (const modelName of candidates) {
    try {
      const response = await fetchFn(
        `https://generativelanguage.googleapis.com/v1beta/models/${modelName}:generateContent?key=${apiKey}`,
        {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({
            contents: [{ parts: [{ text: prompt }] }],
            generationConfig: { responseMimeType: "application/json" },
          }),
          signal: AbortSignal.timeout(15000),
        },
      );
      if (!response.ok) {
        const errText = await response.text().catch(() => "");
        throw new Error(`Gemini API error (${modelName}): ${response.status} - ${errText}`);
      }
      const data = await response.json();
      const parsed = parse(data.candidates?.[0]?.content?.parts?.[0]?.text ?? "");
      if (parsed != null) return parsed;
      throw new Error(`Gemini (${modelName}) returned an empty answer`);
    } catch (err: any) {
      lastError = err;
      console.warn(`Gemini model ${modelName} failed:`, err?.message || err);
    }
  }
  throw lastError;
}
