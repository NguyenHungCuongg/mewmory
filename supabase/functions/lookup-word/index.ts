import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

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

    const {
      word,
      provider = "gemini",
      model,
    }: LookupRequest = await req.json();

    if (!word || typeof word !== "string" || word.trim().length === 0) {
      return new Response(JSON.stringify({ error: "Word is required" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const trimmedWord = word.trim().toLowerCase();

    // Call Dictionary API + AI API in parallel
    const [dictResult, aiResult] = await Promise.allSettled([
      fetchDictionary(trimmedWord),
      fetchAI(trimmedWord, provider, model),
    ]);

    const dictData =
      dictResult.status === "fulfilled" ? dictResult.value : null;
    const aiData = aiResult.status === "fulfilled" ? aiResult.value : null;

    if (!dictData && !aiData) {
      return new Response(
        JSON.stringify({ error: "All lookup services unavailable" }),
        {
          status: 503,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    // Merge results
    const result = mergeResults(trimmedWord, dictData, aiData);

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
  const response = await fetch(
    `https://api.dictionaryapi.dev/api/v2/entries/en/${word}`,
  );
  if (!response.ok) return null;
  return response.json();
}

async function fetchAI(word: string, provider: string, model?: string) {
  const prompt = `You are a vocabulary analysis assistant. Given an English word, provide additional information in JSON format.

Word: "${word}"

Return a JSON object with:
{
  "cefr_level": "A1|A2|B1|B2|C1|C2",
  "usage_register": "formal|informal|slang|neutral|vulgar|technical",
  "vietnamese_definitions": [
    {
      "part_of_speech": "<part of speech>",
      "original_en": "<English definition>",
      "translation_vi": "<Vietnamese translation>",
      "example": "<example sentence>"
    }
  ],
  "suggested_collections": ["<topic categories like Travel, Business, etc.>"]
}

Rules:
- CEFR level should reflect the word's difficulty for learners.
- Vietnamese translations should be natural and contextual, not literal.
- Suggested collections should be broad topic categories.
- Return ONLY valid JSON, no markdown or explanation.`;

  if (provider === "gemini") {
    return callGemini(prompt, model);
  } else {
    return callOpenRouter(prompt, model);
  }
}

async function callGemini(prompt: string, model?: string) {
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

  if (!response.ok) throw new Error(`Gemini API error: ${response.status}`);
  const data = await response.json();
  const text = data.candidates?.[0]?.content?.parts?.[0]?.text;
  return JSON.parse(text);
}

async function callOpenRouter(prompt: string, model?: string) {
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

  if (!response.ok) throw new Error(`OpenRouter API error: ${response.status}`);
  const data = await response.json();
  const text = data.choices?.[0]?.message?.content;
  return JSON.parse(text);
}

function mergeResults(word: string, dictData: any, aiData: any) {
  const result: any = {
    word,
    phonetic: null,
    audio_url: null,
    meanings: [],
    suggested_collections: [],
    source: { dictionary: !!dictData, ai: !!aiData },
  };

  // Extract dictionary data
  if (dictData && Array.isArray(dictData) && dictData.length > 0) {
    const entry = dictData[0];
    result.phonetic =
      entry.phonetic || entry.phonetics?.find((p: any) => p.text)?.text || null;
    result.audio_url =
      entry.phonetics?.find((p: any) => p.audio)?.audio || null;

    for (const meaning of entry.meanings || []) {
      const m: any = {
        part_of_speech: meaning.partOfSpeech,
        cefr_level: aiData?.cefr_level || null,
        usage_register: aiData?.usage_register || null,
        definitions: [],
      };

      for (const def of meaning.definitions || []) {
        const aiVi = aiData?.vietnamese_definitions?.find(
          (v: any) =>
            v.original_en &&
            def.definition &&
            (v.original_en
              .toLowerCase()
              .includes(def.definition.substring(0, 30).toLowerCase()) ||
              def.definition
                .toLowerCase()
                .includes(v.original_en.substring(0, 30).toLowerCase())),
        );

        m.definitions.push({
          definition_en: def.definition || null,
          definition_vi: aiVi?.translation_vi || null,
          example: def.example || aiVi?.example || null,
          synonyms: def.synonyms || [],
          antonyms: def.antonyms || [],
        });
      }

      result.meanings.push(m);
    }
  } else if (aiData?.vietnamese_definitions) {
    // AI-only mode
    const grouped: Record<string, any[]> = {};
    for (const viDef of aiData.vietnamese_definitions) {
      const pos = viDef.part_of_speech || "unknown";
      if (!grouped[pos]) grouped[pos] = [];
      grouped[pos].push(viDef);
    }
    for (const [pos, defs] of Object.entries(grouped)) {
      result.meanings.push({
        part_of_speech: pos,
        cefr_level: aiData.cefr_level || null,
        usage_register: aiData.usage_register || null,
        definitions: defs.map((d: any) => ({
          definition_en: d.original_en || null,
          definition_vi: d.translation_vi || null,
          example: d.example || null,
          synonyms: [],
          antonyms: [],
        })),
      });
    }
  }

  result.suggested_collections = aiData?.suggested_collections || [];

  return result;
}
