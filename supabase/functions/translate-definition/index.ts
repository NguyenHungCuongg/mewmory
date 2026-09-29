import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import {
  getUserIdFromJWT,
  checkBanned,
  logUsage,
  updateLastActive,
  checkAndFlagSpam,
  createAdminClient,
} from "../_shared/admin-utils.ts";
import {
  isRateLimited,
  MAX_TEXT_LENGTH,
  MAX_WORD_LENGTH,
  RATE_LIMIT_PER_HOUR,
  sanitizeModel,
} from "../_shared/ai-guard.ts";
import { geminiGenerate } from "../_shared/gemini.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

interface TranslateRequest {
  word?: string;
  text: string;
  part_of_speech?: string;
  target_lang?: string;
  provider?: "gemini" | "openrouter";
  model?: string;
}

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  let currentUserId: string | null = null;
  let currentAdminClient: any = null;
  let currentWord: string | null = null;

  try {
    // Verify auth
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

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
    currentUserId = userId;
    currentAdminClient = adminClient;

    const banned = await checkBanned(userId, adminClient);
    if (banned) {
      await logUsage(userId, "translate_definition", null, "banned", adminClient);
      return new Response(
        JSON.stringify({ error: "Tài khoản của bạn đã bị khóa." }),
        { status: 403, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }
    if (await isRateLimited(userId, adminClient)) {
      await logUsage(userId, "translate_definition", null, "rate_limited", adminClient);
      return new Response(
        JSON.stringify({
          error: `Bạn đã dùng hết ${RATE_LIMIT_PER_HOUR} lượt AI trong 1 giờ. Vui lòng thử lại sau.`,
        }),
        { status: 429, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }
    await updateLastActive(userId, adminClient);

    const {
      word = "",
      text,
      part_of_speech = "",
      provider = "gemini",
      model: requestedModel,
    }: TranslateRequest = await req.json();
    const model = sanitizeModel(provider, requestedModel);

    // All of these end up in the AI prompt: bound their size.
    const invalidExtras =
      typeof word !== "string" ||
      word.length > MAX_WORD_LENGTH ||
      typeof part_of_speech !== "string" ||
      part_of_speech.length > MAX_WORD_LENGTH;
    currentWord = typeof word === "string" && word ? word.slice(0, MAX_WORD_LENGTH) : null;

    if (
      !text ||
      typeof text !== "string" ||
      text.trim().length === 0 ||
      text.length > MAX_TEXT_LENGTH ||
      invalidExtras
    ) {
      await logUsage(userId, "translate_definition", currentWord, "error", adminClient);
      return new Response(
        JSON.stringify({
          error: `Definition text is required (max ${MAX_TEXT_LENGTH} characters; word/part of speech max ${MAX_WORD_LENGTH})`,
        }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    const prompt = `You are a Vietnamese-English bilingual lexicographer. Given an English word and its dictionary definition, provide the natural Vietnamese equivalent — the word or short phrase a Vietnamese speaker would actually use.

Word: "${word}"
Part of speech: "${part_of_speech}"
English definition: "${text.trim()}"

Rules:
- Return the common Vietnamese EQUIVALENT word or phrase, NOT a literal word-by-word translation of the English definition.
- For example: "supermarket" + "A large self-service store..." → "Siêu thị", NOT "Cửa hàng tự phục vụ lớn...".
- For example: "destination" + "The place to which someone is going" → "Điểm đến, đích đến", NOT "Nơi mà ai đó đang đi tới".
- If the word has a well-known Vietnamese equivalent, use it (e.g. "computer" → "Máy tính").
- If no single-word equivalent exists, use the shortest natural Vietnamese phrase.
- Keep it flashcard-friendly: concise, 1-6 words maximum.
- Match the indicated part of speech.
- Return a JSON object with this exact structure:
{
  "translation": "<Vietnamese equivalent>"
}`;

    // Primary provider first; if all its (free-tier) models fail, try the other one.
    let translation = "";
    try {
      translation = provider === "gemini"
        ? await callGemini(prompt, model)
        : await callOpenRouter(prompt, model);
    } catch (err: any) {
      console.warn(`[translate-definition] ${provider} failed, trying the other provider:`, err?.message || err);
      translation = provider === "gemini" ? await callOpenRouter(prompt) : await callGemini(prompt);
    }

    await logUsage(userId, "translate_definition", word || null, "success", adminClient);
    await checkAndFlagSpam(userId, adminClient);

    return new Response(JSON.stringify({ translation }), {
      status: 200,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (error: any) {
    if (currentUserId && currentAdminClient) {
      await logUsage(currentUserId, "translate_definition", currentWord, "error", currentAdminClient);
    }
    return new Response(
      JSON.stringify({
        error: error.message || "Internal translation error",
      }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  }
});

async function callGemini(prompt: string, model?: string): Promise<string> {
  const apiKey = Deno.env.get("GEMINI_API_KEY");
  if (!apiKey) throw new Error("GEMINI_API_KEY not set");

  // Empty answer = failure, so the next fallback model gets a turn.
  return geminiGenerate(apiKey, prompt, model, (raw) => extractTranslation(raw) || null);
}

function extractTranslation(raw: string): string {
  if (!raw) return "";
  let cleaned = raw.replace(/<think>[\s\S]*?<\/think>/gi, "").trim();
  const markdownMatch = cleaned.match(/```(?:json)?\s*([\s\S]*?)\s*```/i);
  const textToParse = markdownMatch ? markdownMatch[1].trim() : cleaned;

  try {
    const parsed = JSON.parse(textToParse);
    if (parsed && typeof parsed.translation === "string") {
      return parsed.translation.trim();
    }
  } catch {
    const firstBrace = cleaned.indexOf("{");
    const lastBrace = cleaned.lastIndexOf("}");
    if (firstBrace !== -1 && lastBrace !== -1 && lastBrace > firstBrace) {
      try {
        const sliced = cleaned.substring(firstBrace, lastBrace + 1);
        const parsed = JSON.parse(sliced);
        if (parsed && typeof parsed.translation === "string") {
          return parsed.translation.trim();
        }
      } catch {
        // ignore
      }
    }
  }

  return cleaned.replace(/^["']|["']$/g, "").trim();
}

async function callOpenRouter(prompt: string, model?: string): Promise<string> {
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
): Promise<string> {
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
      signal: AbortSignal.timeout(45000),
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
  const rawContent =
    choice?.message?.content || choice?.message?.reasoning || "";
  return extractTranslation(rawContent);
}
