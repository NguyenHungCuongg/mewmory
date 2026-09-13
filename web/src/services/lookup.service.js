import { supabase } from "../config/supabase";

export const lookupService = {
  async lookupWord(word, provider = "gemini", model = null) {
    const { data, error } = await supabase.functions.invoke("lookup-word", {
      body: { word: word.trim(), provider, model },
    });

    if (error) throw error;
    return data;
  },

  async translateDefinition({
    text,
    partOfSpeech = "",
    word = "",
    targetLang = "vi",
    provider = "gemini",
    model = null,
  }) {
    if (!text || typeof text !== "string" || text.trim().length === 0) {
      return "";
    }

    const { data, error } = await supabase.functions.invoke(
      "translate-definition",
      {
        body: {
          text: text.trim(),
          part_of_speech: partOfSpeech,
          word,
          target_lang: targetLang,
          provider,
          model,
        },
      },
    );

    if (error) throw error;
    return data?.translation || "";
  },
};
