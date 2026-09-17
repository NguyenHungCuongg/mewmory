import { useState, useCallback } from "react";
import { useNavigate } from "react-router-dom";
import { useTranslation } from "react-i18next";
import { useAuthStore } from "../stores/auth.store";
import { useUIStore } from "../stores/ui.store";
import { vocabularyService } from "../services/vocabulary.service";

export function useWordSave({ defaultColId } = {}) {
  const { t } = useTranslation("addWord");
  const navigate = useNavigate();
  const { user } = useAuthStore();
  const addToast = useUIStore((s) => s.addToast);

  const [selectedMeanings, setSelectedMeanings] = useState({});
  const [isSaving, setIsSaving] = useState(false);

  const autoSelectAllMeanings = useCallback((result) => {
    const selection = {};
    result?.meanings?.forEach((m, mIdx) => {
      m.definitions?.forEach((_, dIdx) => {
        selection[`${mIdx}-${dIdx}`] = { meaningIdx: mIdx, defIdx: dIdx };
      });
    });
    setSelectedMeanings(selection);
  }, []);

  const handleManualSave = async ({
    vocabulary,
    definitions,
    collectionIds,
  }) => {
    if (!user) return;
    setIsSaving(true);
    try {
      await vocabularyService.create(
        {
          ...vocabulary,
          user_id: user.id,
        },
        definitions,
        collectionIds,
      );
      addToast(t("toastSuccess"), "success");
      navigate(defaultColId ? `/collections/${defaultColId}` : "/vocabulary");
    } catch (err) {
      addToast(err.message || t("toastSaveError"), "error");
    } finally {
      setIsSaving(false);
    }
  };

  const handleSave = async ({
    lookupResult,
    editFields = {},
    selectedColIds = [],
    word = "",
  }) => {
    if (!user || Object.keys(selectedMeanings).length === 0) {
      addToast(t("toastSelectMeaning"), "error");
      return;
    }

    setIsSaving(true);
    try {
      // Group selected definitions by meaning (part_of_speech)
      const groupedByMeaning = {};
      for (const [key, { meaningIdx, defIdx }] of Object.entries(
        selectedMeanings,
      )) {
        if (!groupedByMeaning[meaningIdx]) groupedByMeaning[meaningIdx] = [];
        groupedByMeaning[meaningIdx].push(defIdx);
      }

      // Create one vocabulary entry per part_of_speech
      for (const [mIdxStr, defIndices] of Object.entries(groupedByMeaning)) {
        const mIdx = parseInt(mIdxStr, 10);
        const meaning = lookupResult?.meanings?.[mIdx];
        if (!meaning) continue;

        const vocabData = {
          user_id: user.id,
          word: lookupResult?.word || word.trim(),
          phonetic: editFields.phonetic || lookupResult?.phonetic || null,
          audio_url: lookupResult?.audio_url || null,
          part_of_speech: meaning.part_of_speech || null,
          cefr_level: editFields.cefr_level || meaning.cefr_level || null,
          usage_register:
            editFields.usage_register || meaning.usage_register || null,
        };

        const definitions = defIndices
          .map((dIdx) => meaning.definitions?.[dIdx])
          .filter(Boolean);

        if (definitions.length > 0) {
          await vocabularyService.create(vocabData, definitions, selectedColIds);
        }
      }

      addToast(t("toastSaved"), "success");
      navigate(defaultColId ? `/collections/${defaultColId}` : "/vocabulary");
    } catch (err) {
      addToast(err.message || t("toastSaveError"), "error");
    } finally {
      setIsSaving(false);
    }
  };

  return {
    selectedMeanings,
    setSelectedMeanings,
    isSaving,
    autoSelectAllMeanings,
    handleSave,
    handleManualSave,
  };
}
