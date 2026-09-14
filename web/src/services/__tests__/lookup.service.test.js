import { describe, it, expect, vi, beforeEach } from "vitest";
import { lookupService } from "../lookup.service";
import { supabase } from "../../config/supabase";

vi.mock("../../config/supabase", () => ({
  supabase: {
    functions: {
      invoke: vi.fn(),
    },
  },
}));

describe("lookupService", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  describe("lookupWord", () => {
    it("calls lookup-word edge function and returns data", async () => {
      const mockData = { word: "run", meanings: [] };
      supabase.functions.invoke.mockResolvedValueOnce({
        data: mockData,
        error: null,
      });

      const result = await lookupService.lookupWord("run");
      expect(supabase.functions.invoke).toHaveBeenCalledWith("lookup-word", {
        body: { word: "run", provider: "gemini", model: null },
      });
      expect(result).toEqual(mockData);
    });

    it("returns lookup result including fallback phonetic and audio_url", async () => {
      const mockData = {
        word: "resilient",
        phonetic: "/rɪˈzɪl.jənt/",
        audio_url: null,
        meanings: [],
        source: { dictionary: true, ai: true },
      };
      supabase.functions.invoke.mockResolvedValueOnce({
        data: mockData,
        error: null,
      });

      const result = await lookupService.lookupWord("resilient");
      expect(result.phonetic).toBe("/rɪˈzɪl.jənt/");
      expect(result.source.ai).toBe(true);
    });

    it("throws error when edge function returns error", async () => {
      supabase.functions.invoke.mockResolvedValueOnce({
        data: null,
        error: new Error("Lookup failed"),
      });

      await expect(lookupService.lookupWord("badword")).rejects.toThrow(
        "Lookup failed",
      );
    });
  });

  describe("translateDefinition", () => {
    it("returns empty string if text is empty or missing", async () => {
      const res1 = await lookupService.translateDefinition({ text: "" });
      const res2 = await lookupService.translateDefinition({ text: null });
      expect(res1).toBe("");
      expect(res2).toBe("");
      expect(supabase.functions.invoke).not.toHaveBeenCalled();
    });

    it("calls translate-definition edge function and returns translation", async () => {
      supabase.functions.invoke.mockResolvedValueOnce({
        data: { translation: "điểm đến, đích đến" },
        error: null,
      });

      const result = await lookupService.translateDefinition({
        text: "The place to which someone or something is going",
        partOfSpeech: "noun",
        word: "destination",
      });

      expect(supabase.functions.invoke).toHaveBeenCalledWith(
        "translate-definition",
        {
          body: {
            text: "The place to which someone or something is going",
            part_of_speech: "noun",
            word: "destination",
            target_lang: "vi",
            provider: "gemini",
            model: null,
          },
        },
      );
      expect(result).toBe("điểm đến, đích đến");
    });

    it("throws error if translate-definition returns error", async () => {
      supabase.functions.invoke.mockResolvedValueOnce({
        data: null,
        error: new Error("Translation failed"),
      });

      await expect(
        lookupService.translateDefinition({
          text: "Some definition",
        }),
      ).rejects.toThrow("Translation failed");
    });
  });
});
