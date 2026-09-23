import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import {
  getUserIdFromJWT,
  checkBanned,
  logUsage,
  updateLastActive,
  checkAndFlagSpam,
  createAdminClient,
} from "../_shared/admin-utils.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

interface LookupRequest {
  word: string;
  provider?: "gemini" | "openrouter";
  model?: string;
}

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    // Verify auth
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // Resolve user_id from JWT
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY")!;
    const userId = await getUserIdFromJWT(authHeader, supabaseUrl, supabaseAnonKey);
    if (!userId) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const adminClient = createAdminClient();

    // Ban check — must happen before reading body to avoid wasted work
    const banned = await checkBanned(userId, adminClient);
    if (banned) {
      await logUsage(userId, "lookup_word", null, "banned", adminClient);
      return new Response(
        JSON.stringify({ error: "Tài khoản của bạn đã bị khóa." }),
        {
          status: 403,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    await updateLastActive(userId, adminClient);

    const {
      word,
      provider = "gemini",
      model,
    }: LookupRequest = await req.json();

    if (!word || typeof word !== "string" || word.trim().length === 0) {
      await logUsage(userId, "lookup_word", null, "error", adminClient);
      return new Response(JSON.stringify({ error: "Word is required" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const trimmedWord = word.trim().toLowerCase();

    const [dictResult, aiResult] = await Promise.allSettled([
      fetchDictionary(trimmedWord),
      fetchAI(trimmedWord, provider, model),
    ]);

    const dictData =
      dictResult.status === "fulfilled" ? dictResult.value : null;
    const aiData = aiResult.status === "fulfilled" ? aiResult.value : null;

    if (!dictData && !aiData) {
      await logUsage(userId, "lookup_word", trimmedWord, "error", adminClient);
      await checkAndFlagSpam(userId, adminClient);

      const dictErr =
        dictResult.status === "rejected"
          ? String(dictResult.reason?.message || dictResult.reason)
          : "null/timeout";
      const aiErr =
        aiResult.status === "rejected"
          ? String(aiResult.reason?.message || aiResult.reason)
          : aiData === null
            ? "returned_null_or_empty"
            : null;

      console.error(`[lookup-word] All services failed for "${trimmedWord}":`, {
        dictErr,
        aiErr,
      });

      return new Response(
        JSON.stringify({ error: "All lookup services unavailable" }),
        {
          status: 503,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // Merge results
    const result = mergeResults(trimmedWord, dictData, aiData);

    await logUsage(userId, "lookup_word", trimmedWord, "success", adminClient);
    await checkAndFlagSpam(userId, adminClient);

    return new Response(JSON.stringify(result), {
      status: 200,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (error) {
    return new Response(JSON.stringify({ error: "Internal server error" }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});

async function fetchDictionary(word: string) {
  try {
    const response = await fetch(
      `https://api.dictionaryapi.dev/api/v2/entries/en/${encodeURIComponent(word)}`,
      { signal: AbortSignal.timeout(10000) },
    );
    if (!response.ok) return null;
    return await response.json();
  } catch {
    return null;
  }
}

async function fetchAI(word: string, provider: string, model?: string) {
  const prompt = `You are a vocabulary analysis assistant. Given an English word, provide its accurate international phonetic alphabet (IPA) transcription, CEFR level, usage register, and suggested collection topics in JSON format. Also provide basic English definitions in case the word is not in standard dictionaries.

Word: "${word}"

Return a JSON object with:
{
  "phonetic": "<accurate IPA transcription with slashes, e.g. /həˈloʊ/ or /rɪˈzɪl.jənt/>",
  "cefr_level": "A1|A2|B1|B2|C1|C2",
  "usage_register": "formal|informal|slang|neutral|vulgar|technical",
  "suggested_collections": ["<topic categories like Travel, Business, Daily Life, etc.>"],
  "definitions": [
    {
      "part_of_speech": "noun|verb|adjective|adverb|etc",
      "definition_en": "<clear English definition>",
      "example": "<natural English example sentence>"
    }
  ]
}

Rules:
- phonetic MUST be an accurate IPA transcription enclosed in slashes (e.g. /rɪˈzɪl.jənt/).
- CEFR level should reflect the word's general difficulty for English learners.
- usage_register must be one of: formal, informal, slang, neutral, vulgar, technical.
- suggested_collections should contain 1-3 broad topic names.
- definitions should provide 1 to 3 primary meanings (used as fallback if dictionary is unavailable).
- Return ONLY valid JSON, no markdown formatting or extra text.`;

  if (provider === "gemini") {
    return callGemini(prompt, model);
  } else {
    return callOpenRouter(prompt, model);
  }
}

async function callGemini(prompt: string, model?: string) {
  const apiKey = Deno.env.get("GEMINI_API_KEY");
  if (!apiKey) throw new Error("GEMINI_API_KEY not set");

  const requestedModel = model || "gemini-3.5-flash-lite";
  const candidateModels = [
    requestedModel,
    "gemini-3.5-flash-lite",
    "gemini-3.1-flash-lite",
    "gemini-3.6-flash",
  ].filter((m, idx, arr) => arr.indexOf(m) === idx);

  let lastError: any = null;
  for (const modelName of candidateModels) {
    try {
      const response = await fetch(
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
        lastError = new Error(
          `Gemini API error (${modelName}): ${response.status} - ${errText}`,
        );
        // If high demand (503), rate limit (429), or discontinued model (404), try fallback model
        if (
          response.status === 503 ||
          response.status === 429 ||
          response.status === 404
        ) {
          console.warn(
            `Gemini model ${modelName} returned ${response.status}. Trying next fallback model...`,
          );
          continue;
        }
        throw lastError;
      }

      const data = await response.json();
      const text = data.candidates?.[0]?.content?.parts?.[0]?.text;
      const parsed = extractJSON(text);
      if (parsed) return parsed;
    } catch (err: any) {
      lastError = err;
      console.warn(`Gemini model ${modelName} failed:`, err?.message || err);
    }
  }

  throw lastError || new Error("All Gemini candidate models failed");
}

function extractJSON(raw: string): any {
  if (!raw) return null;
  let cleaned = raw.replace(/<think>[\s\S]*?<\/think>/gi, "").trim();
  const markdownMatch = cleaned.match(/```(?:json)?\s*([\s\S]*?)\s*```/i);
  const textToParse = markdownMatch ? markdownMatch[1].trim() : cleaned;

  try {
    return JSON.parse(textToParse);
  } catch {
    const firstBrace = cleaned.indexOf("{");
    const lastBrace = cleaned.lastIndexOf("}");
    if (firstBrace !== -1 && lastBrace !== -1 && lastBrace > firstBrace) {
      const sliced = cleaned.substring(firstBrace, lastBrace + 1);
      return JSON.parse(sliced);
    }
    throw new Error(
      `Failed to parse AI response as JSON: ${raw.slice(0, 120)}`,
    );
  }
}

async function callOpenRouter(prompt: string, model?: string) {
  const apiKey = Deno.env.get("OPENROUTER_API_KEY");
  if (!apiKey) throw new Error("OPENROUTER_API_KEY not set");

  const primaryModel = model || "google/gemma-4-31b-it:free";

  try {
    return await executeOpenRouterRequest(apiKey, prompt, primaryModel);
  } catch (err: any) {
    if (primaryModel === "google/gemma-4-31b-it:free") {
      console.warn(
        "Gemma 4 31B error, falling back to nvidia/nemotron-3.5-lightning:free:",
        err.message,
      );
      return await executeOpenRouterRequest(
        apiKey,
        prompt,
        "nvidia/nemotron-3.5-lightning:free",
      );
    }
    throw err;
  }
}

async function executeOpenRouterRequest(
  apiKey: string,
  prompt: string,
  modelName: string,
) {
  const requestBody: any = {
    model: modelName,
    messages: [{ role: "user", content: prompt }],
  };

  const response = await fetch(
    "https://openrouter.ai/api/v1/chat/completions",
    {
      method: "POST",
      headers: {
        Authorization: `Bearer ${apiKey}`,
        "Content-Type": "application/json",
        "HTTP-Referer": "https://mewmory.app",
        "X-Title": "Mewmory",
      },
      body: JSON.stringify(requestBody),
      signal: AbortSignal.timeout(15000),
    },
  );

  if (!response.ok) {
    const errText = await response.text();
    console.error(`OpenRouter error ${response.status}:`, errText);
    throw new Error(`OpenRouter API error: ${response.status} - ${errText}`);
  }

  const data = await response.json();
  if (data.error) {
    console.error("OpenRouter payload error:", data.error);
    throw new Error(
      `OpenRouter error: ${data.error.message || JSON.stringify(data.error)}`,
    );
  }

  const choice = data.choices?.[0];
  const text = choice?.message?.content || choice?.message?.reasoning;
  return extractJSON(text);
}

function mergeResults(word: string, dictData: any, aiData: any) {
  const result: any = {
    word,
    phonetic: null,
    audio_url: null,
    meanings: [],
    suggested_collections: aiData?.suggested_collections || [],
    source: { dictionary: !!dictData, ai: !!aiData },
  };

  // Extract dictionary data
  if (dictData && Array.isArray(dictData) && dictData.length > 0) {
    const entry = dictData[0];
    result.phonetic =
      entry.phonetic ||
      entry.phonetics?.find((p: any) => p.text)?.text ||
      aiData?.phonetic ||
      null;
    result.audio_url =
      entry.phonetics?.find((p: any) => p.audio)?.audio || null;

    for (const meaning of entry.meanings || []) {
      const m: any = {
        part_of_speech: meaning.partOfSpeech || "other",
        cefr_level: aiData?.cefr_level || null,
        usage_register: aiData?.usage_register || null,
        definitions: (meaning.definitions || []).map((def: any) => ({
          definition_en: def.definition || null,
          definition_vi: null, // User translates on demand
          example: def.example || null,
          synonyms: def.synonyms || [],
          antonyms: def.antonyms || [],
        })),
      };
      result.meanings.push(m);
    }
  } else if (aiData?.definitions && Array.isArray(aiData.definitions)) {
    // Fallback if Dictionary API returned no entry
    result.phonetic = aiData.phonetic || null;
    const grouped: Record<string, any[]> = {};
    for (const d of aiData.definitions) {
      const pos = d.part_of_speech || "other";
      if (!grouped[pos]) grouped[pos] = [];
      grouped[pos].push(d);
    }
    for (const [pos, defs] of Object.entries(grouped)) {
      result.meanings.push({
        part_of_speech: pos,
        cefr_level: aiData.cefr_level || null,
        usage_register: aiData.usage_register || null,
        definitions: defs.map((d: any) => ({
          definition_en: d.definition_en || null,
          definition_vi: null,
          example: d.example || null,
          synonyms: [],
          antonyms: [],
        })),
      });
    }
  } else if (aiData?.phonetic) {
    result.phonetic = aiData.phonetic;
  }

  return result;
}
