import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

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

  try {
    // Verify auth
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const {
      word = "",
      text,
      part_of_speech = "",
      provider = "gemini",
      model,
    }: TranslateRequest = await req.json();

    if (!text || typeof text !== "string" || text.trim().length === 0) {
      return new Response(
        JSON.stringify({ error: "Definition text is required" }),
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

    let translation = "";
    if (provider === "gemini") {
      translation = await callGemini(prompt, model);
    } else {
      translation = await callOpenRouter(prompt, model);
    }

    return new Response(JSON.stringify({ translation }), {
      status: 200,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (error: any) {
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

  const modelName = model || "gemini-3.6-flash";
  const response = await fetch(
    `https://generativelanguage.googleapis.com/v1beta/models/${modelName}:generateContent?key=${apiKey}`,
    {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        contents: [{ parts: [{ text: prompt }] }],
        generationConfig: { responseMimeType: "application/json" },
      }),
    },
  );

  if (!response.ok) {
    throw new Error(`Gemini API error: ${response.status}`);
  }

  const data = await response.json();
  const rawText = data.candidates?.[0]?.content?.parts?.[0]?.text;
  if (!rawText) return "";

  try {
    const parsed = JSON.parse(rawText);
    return parsed.translation || "";
  } catch {
    return rawText.trim();
  }
}

async function callOpenRouter(prompt: string, model?: string): Promise<string> {
  const apiKey = Deno.env.get("OPENROUTER_API_KEY");
  if (!apiKey) throw new Error("OPENROUTER_API_KEY not set");

  const modelName = model || "meta-llama/llama-3.1-8b-instruct:free";
  const response = await fetch(
    "https://openrouter.ai/api/v1/chat/completions",
    {
      method: "POST",
      headers: {
        Authorization: `Bearer ${apiKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        model: modelName,
        messages: [{ role: "user", content: prompt }],
        response_format: { type: "json_object" },
      }),
    },
  );

  if (!response.ok) {
    throw new Error(`OpenRouter API error: ${response.status}`);
  }

  const data = await response.json();
  const rawContent = data.choices?.[0]?.message?.content;
  if (!rawContent) return "";

  try {
    const parsed = JSON.parse(rawContent);
    return parsed.translation || "";
  } catch {
    return rawContent.trim();
  }
}
