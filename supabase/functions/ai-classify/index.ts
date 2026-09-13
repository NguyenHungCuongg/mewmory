import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const {
      word,
      definitions_vi,
      existing_collections,
      provider = "gemini",
      model,
    } = await req.json();

    if (!word) {
      return new Response(JSON.stringify({ error: "Word is required" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const prompt = `Given the English word "${word}" with Vietnamese meanings: ${JSON.stringify(definitions_vi)}, and the user's existing collections: ${JSON.stringify(existing_collections)}, suggest appropriate collections for this word.

Return a JSON object:
{
  "suggested_collections": ["<all suggested collections>"],
  "new_collections": ["<collections that don't exist yet>"],
  "existing_matches": ["<collections that already exist and match>"]
}

Rules:
- Prefer matching existing collections when appropriate.
- Suggest 1-3 collections maximum.
- Use broad, reusable topic names (Travel, Business, Technology, etc.).
- Return ONLY valid JSON.`;

    let result: any;
    if (provider === "gemini") {
      result = await callGemini(prompt, model);
    } else {
      result = await callOpenRouter(prompt, model);
    }

    return new Response(JSON.stringify(result), {
      status: 200,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (error: any) {
    console.error("ai-classify error:", error);
    return new Response(
      JSON.stringify({ error: error.message || "Internal server error" }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  }
});

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
    throw new Error(`Failed to parse AI response as JSON: ${raw.slice(0, 120)}`);
  }
}

async function callGemini(prompt: string, model?: string) {
  const apiKey = Deno.env.get("GEMINI_API_KEY");
  if (!apiKey) throw new Error("GEMINI_API_KEY not configured");

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

  if (!response.ok) throw new Error(`AI API error: ${response.status}`);
  const data = await response.json();
  const text = data.candidates?.[0]?.content?.parts?.[0]?.text;
  return extractJSON(text);
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
  const text = choice?.message?.content || choice?.message?.reasoning;
  return extractJSON(text);
}
