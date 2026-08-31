import { supabase } from "../config/supabase";

export const lookupService = {
  async lookupWord(word, provider = "gemini", model = null) {
    const { data, error } = await supabase.functions.invoke("lookup-word", {
      body: { word: word.trim(), provider, model },
    });

    if (error) throw error;
    return data;
  },
};
