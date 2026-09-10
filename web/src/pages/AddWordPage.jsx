import { useState, useEffect, useCallback } from "react";
import { useNavigate, useSearchParams } from "react-router-dom";
import { useTranslation } from "react-i18next";
import { useAuthStore } from "../stores/auth.store";
import { useCollectionStore } from "../stores/collection.store";
import { useSettingsStore } from "../stores/settings.store";
import { useUIStore } from "../stores/ui.store";
import { vocabularyService } from "../services/vocabulary.service";
import { lookupService } from "../services/lookup.service";
import { useOnlineStatus } from "../hooks/useOnlineStatus";
import { useDebouncedSearch } from "../hooks/useDebouncedSearch";
import { validateWord } from "../utils/validators";
import Header from "../components/layout/Header";
import Button from "../components/common/Button";
import Input from "../components/common/Input";
import LoadingSpinner from "../components/common/LoadingSpinner";
import LookupResult from "../components/vocabulary/LookupResult";
import MeaningSelector from "../components/vocabulary/MeaningSelector";
import DuplicateWarning from "../components/vocabulary/DuplicateWarning";
import WordForm from "../components/vocabulary/WordForm";

export default function AddWordPage() {
  const { t } = useTranslation(["addWord", "wordForm"]);
  const navigate = useNavigate();
  const [searchParams] = useSearchParams();
  const defaultColId = searchParams.get("collectionId");
  const { user } = useAuthStore();
  const { settings, fetchSettings } = useSettingsStore();
  const { items: collections, fetchCollections, addCollection } =
    useCollectionStore();
  const addToast = useUIStore((s) => s.addToast);
  const { isOnline } = useOnlineStatus();

  useEffect(() => {
    if (user?.id && !settings) {
      fetchSettings(user.id);
    }
  }, [user, settings, fetchSettings]);

  const [mode, setMode] = useState("auto"); // "auto" | "manual"
  const [word, setWord] = useState("");
  const [lookupResult, setLookupResult] = useState(null);
  const [selectedMeanings, setSelectedMeanings] = useState({});
  const [selectedColIds, setSelectedColIds] = useState(
    defaultColId ? [defaultColId] : [],
  );
  const [isLooking, setIsLooking] = useState(false);
  const [isSaving, setIsSaving] = useState(false);
  const [duplicateCount, setDuplicateCount] = useState(0);
  const [wordError, setWordError] = useState("");

  // Quick collection creation
  const [isCreatingCol, setIsCreatingCol] = useState(false);
  const [newColName, setNewColName] = useState("");
  const [isSubmittingCol, setIsSubmittingCol] = useState(false);

  // Manual field overrides
  const [editFields, setEditFields] = useState({
    phonetic: "",
    cefr_level: "",
    usage_register: "",
  });

  const handleQuickCreateCollection = async (e) => {
    if (e) e.preventDefault();
    if (!user || !newColName.trim() || isSubmittingCol) return;
    setIsSubmittingCol(true);
    try {
      const newCol = await addCollection({
        user_id: user.id,
        name: newColName.trim(),
      });
      if (newCol?.id) {
        setSelectedColIds((prev) => [...prev, newCol.id]);
      }
      setNewColName("");
      setIsCreatingCol(false);
      addToast(
        t("toastColCreated", { name: newCol?.name || newColName }),
        "success",
      );
    } catch (err) {
      addToast(err.message || t("toastColError"), "error");
    } finally {
      setIsSubmittingCol(false);
    }
  };

  const handleCreateFromSuggestion = async (suggestedName) => {
    if (!user || isSubmittingCol) return;
    setIsSubmittingCol(true);
    try {
      const newCol = await addCollection({
        user_id: user.id,
        name: suggestedName.trim(),
        is_ai_generated: true,
      });
      if (newCol?.id) {
        setSelectedColIds((prev) => [...prev, newCol.id]);
      }
      addToast(t("toastColCreated", { name: suggestedName }), "success");
    } catch (err) {
      addToast(err.message || t("toastColError"), "error");
    } finally {
      setIsSubmittingCol(false);
    }
  };

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

  const debouncedWord = useDebouncedSearch(word, 300);

  // Fetch collections
  useEffect(() => {
    if (user) {
      fetchCollections(user.id);
    }
  }, [user, fetchCollections]);

  // Check for duplicates on debounced word change
  useEffect(() => {
    if (debouncedWord && user) {
      vocabularyService
        .checkDuplicate(user.id, debouncedWord)
        .then(({ count }) => setDuplicateCount(count));
    } else {
      setDuplicateCount(0);
    }
  }, [debouncedWord, user]);

  const handleLookup = async () => {
    const validation = validateWord(word);
    if (!validation.valid) {
      setWordError(validation.error);
      return;
    }
    setWordError("");

    if (!isOnline) {
      addToast(t("toastNetworkRequired"), "error");
      return;
    }

    setIsLooking(true);
    try {
      const provider = settings?.ai_provider || "gemini";
      const model = settings?.ai_model || undefined;
      const result = await lookupService.lookupWord(word, provider, model);
      setLookupResult(result);
      setEditFields({
        phonetic: result.phonetic || "",
        cefr_level: result.meanings?.[0]?.cefr_level || "",
        usage_register: result.meanings?.[0]?.usage_register || "",
      });
      // Auto-select all meanings
      const selection = {};
      result.meanings?.forEach((m, mIdx) => {
        m.definitions?.forEach((_, dIdx) => {
          selection[`${mIdx}-${dIdx}`] = { meaningIdx: mIdx, defIdx: dIdx };
        });
      });
      setSelectedMeanings(selection);
    } catch (err) {
      addToast(err.message || t("toastLookupError"), "error");
    } finally {
      setIsLooking(false);
    }
  };

  const handleSave = async () => {
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
        const mIdx = parseInt(mIdxStr);
        const meaning = lookupResult.meanings[mIdx];
        if (!meaning) continue;

        const vocabData = {
          user_id: user.id,
          word: lookupResult.word || word.trim(),
          phonetic: editFields.phonetic || lookupResult.phonetic || null,
          audio_url: lookupResult.audio_url || null,
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

  const handlePlayAudio = (url) => {
    const audio = new Audio(url);
    audio.play().catch(() => addToast(t("toastAudioError"), "error"));
  };

  const handleKeyDown = (e) => {
    if (e.key === "Enter") handleLookup();
  };

  const manualInitialData = {
    vocabulary: {
      word: word.trim(),
      phonetic: editFields.phonetic || lookupResult?.phonetic || "",
      part_of_speech: lookupResult?.meanings?.[0]?.part_of_speech || "",
      cefr_level:
        editFields.cefr_level || lookupResult?.meanings?.[0]?.cefr_level || "",
      usage_register:
        editFields.usage_register ||
        lookupResult?.meanings?.[0]?.usage_register ||
        "",
    },
    definitions: lookupResult?.meanings?.[0]?.definitions?.length
      ? lookupResult.meanings[0].definitions
      : [{ definition_en: "", definition_vi: "", example: "" }],
  };

  return (
    <>
      <Header title={t("title")} />
      <div className="p-6 max-w-2xl mx-auto">
        {/* Mode Switcher */}
        <div className="flex bg-warm-taupe p-1 rounded-xl border border-stone mb-6">
          <button
            type="button"
            onClick={() => setMode("auto")}
            className={`flex-1 flex items-center justify-center gap-2 py-2.5 px-4 rounded-lg text-body-sm font-medium transition-all ${
              mode === "auto"
                ? "bg-eggshell text-ink shadow-subtle"
                : "text-smoke hover:text-ink"
            }`}
          >
            <span>⚡</span>
            <span>{t("modes.auto")}</span>
          </button>
          <button
            type="button"
            onClick={() => setMode("manual")}
            className={`flex-1 flex items-center justify-center gap-2 py-2.5 px-4 rounded-lg text-body-sm font-medium transition-all ${
              mode === "manual"
                ? "bg-eggshell text-ink shadow-subtle"
                : "text-smoke hover:text-ink"
            }`}
          >
            <span>✍️</span>
            <span>{t("modes.manual")}</span>
          </button>
        </div>

        {mode === "manual" ? (
          <WordForm
            key={`manual-${word}`}
            initialData={manualInitialData}
            collections={collections}
            assignedCollectionIds={selectedColIds}
            onSubmit={handleManualSave}
            onCancel={() =>
              navigate(
                defaultColId ? `/collections/${defaultColId}` : "/vocabulary",
              )
            }
            isSubmitting={isSaving}
            submitLabel={t("wordForm:createDefault")}
          />
        ) : (
          <>
            {/* Word input */}
            <div className="flex gap-3 mb-4">
              <Input
                id="word-input"
                placeholder={t("searchPlaceholder")}
                value={word}
                onChange={(e) => setWord(e.target.value)}
                onKeyDown={handleKeyDown}
                error={wordError}
                className="flex-1"
              />
              <Button onClick={handleLookup} disabled={isLooking || !isOnline}>
                {isLooking ? <LoadingSpinner size="sm" /> : t("lookupButton")}
              </Button>
            </div>

            {/* Duplicate warning */}
            <DuplicateWarning count={duplicateCount} />

            {/* Offline notice */}
            {!isOnline && (
              <div className="mt-4 p-4 bg-amber-50 border border-amber-200 dark:bg-amber-950/70 dark:text-amber-300 dark:border-amber-800 rounded-card text-body-sm text-amber-800 flex items-center justify-between gap-4">
                <div>
                  <p className="font-medium">
                    {t("offlineTitle")}
                  </p>
                  <p className="text-caption mt-0.5 opacity-90">
                    {t("offlineNotice")}
                  </p>
                </div>
                <Button
                  size="sm"
                  variant="secondary"
                  onClick={() => setMode("manual")}
                >
                  {t("manualSwitch")}
                </Button>
              </div>
            )}

            {/* Loading */}
            {isLooking && (
              <div className="flex items-center justify-center py-12">
                <LoadingSpinner size="lg" />
              </div>
            )}

            {/* Results */}
            {lookupResult && !isLooking && (
              <div className="mt-6 flex flex-col gap-6">
                <LookupResult
                  result={lookupResult}
                  onPlayAudio={handlePlayAudio}
                />

                {/* Editable fields */}
                <div className="grid grid-cols-3 gap-4">
                  <Input
                    id="phonetic"
                    label={t("wordForm:phonetic")}
                    value={editFields.phonetic}
                    onChange={(e) =>
                      setEditFields({ ...editFields, phonetic: e.target.value })
                    }
                  />
                  <div className="flex flex-col gap-1.5">
                    <label className="text-body-sm text-graphite font-medium">
                      {t("wordForm:cefrLevel")}
                    </label>
                    <select
                      value={editFields.cefr_level}
                      onChange={(e) =>
                        setEditFields({
                          ...editFields,
                          cefr_level: e.target.value,
                        })
                      }
                      className="w-full px-3 py-2 rounded border border-stone bg-eggshell text-body"
                    >
                      <option value="">—</option>
                      {["A1", "A2", "B1", "B2", "C1", "C2"].map((l) => (
                        <option key={l} value={l}>
                          {l}
                        </option>
                      ))}
                    </select>
                  </div>
                  <div className="flex flex-col gap-1.5">
                    <label className="text-body-sm text-graphite font-medium">
                      {t("wordForm:usageRegister")}
                    </label>
                    <select
                      value={editFields.usage_register}
                      onChange={(e) =>
                        setEditFields({
                          ...editFields,
                          usage_register: e.target.value,
                        })
                      }
                      className="w-full px-3 py-2 rounded border border-stone bg-eggshell text-body"
                    >
                      <option value="">—</option>
                      {[
                        "formal",
                        "informal",
                        "slang",
                        "neutral",
                        "vulgar",
                        "technical",
                      ].map((u) => (
                        <option key={u} value={u}>
                          {u}
                        </option>
                      ))}
                    </select>
                  </div>
                </div>

                {/* Meaning selection */}
                <div>
                  <h3 className="text-subheading font-display font-light mb-3">
                    {t("selectMeaningsTitle")}
                  </h3>
                  <MeaningSelector
                    meanings={lookupResult.meanings}
                    selectedMeanings={selectedMeanings}
                    word={lookupResult.word || word}
                    onSelectionChange={setSelectedMeanings}
                    onMeaningsChange={(newMeanings) =>
                      setLookupResult((prev) => ({
                        ...prev,
                        meanings: newMeanings,
                      }))
                    }
                    provider={settings?.ai_provider}
                    model={settings?.ai_model}
                  />
                </div>

                {/* Collection assignment */}
                <div className="card-taupe flex flex-col gap-3">
                  <div className="flex items-center justify-between">
                    <h3 className="text-subheading font-display font-light text-ink">
                      {t("collectionsTitle")}
                    </h3>
                    {!isCreatingCol && (
                      <button
                        type="button"
                        onClick={() => setIsCreatingCol(true)}
                        className="text-caption text-ink font-medium px-2.5 py-1 rounded-pill border border-stone bg-eggshell hover:bg-warm-taupe transition-colors flex items-center gap-1 cursor-pointer"
                      >
                        <span>{t("createCollection")}</span>
                      </button>
                    )}
                  </div>
                  <p className="text-caption text-smoke">
                    {t("collectionsDesc")}
                  </p>

                  {/* Inline quick create collection form */}
                  {isCreatingCol && (
                    <form
                      onSubmit={handleQuickCreateCollection}
                      className="flex items-center gap-2 p-2 rounded-card bg-eggshell border border-stone"
                    >
                      <input
                        type="text"
                        value={newColName}
                        onChange={(e) => setNewColName(e.target.value)}
                        placeholder={t("newColPlaceholder")}
                        autoFocus
                        className="flex-1 px-3 py-1 text-body-sm bg-warm-taupe/40 dark:bg-stone/30 border border-stone rounded outline-none text-ink placeholder:text-ash focus:border-ink"
                      />
                      <Button
                        size="sm"
                        type="submit"
                        disabled={!newColName.trim() || isSubmittingCol}
                      >
                        {isSubmittingCol ? "..." : t("createColButton")}
                      </Button>
                      <Button
                        size="sm"
                        variant="ghost"
                        type="button"
                        onClick={() => {
                          setIsCreatingCol(false);
                          setNewColName("");
                        }}
                      >
                        {t("cancelButton")}
                      </Button>
                    </form>
                  )}

                  {collections.length > 0 ? (
                    <div className="flex flex-wrap gap-2">
                      {collections.map((col) => {
                        const isSelected = selectedColIds.includes(col.id);
                        const isAiSuggested =
                          lookupResult?.suggested_collections?.some(
                            (sc) => sc.toLowerCase() === col.name.toLowerCase(),
                          );

                        return (
                          <button
                            key={col.id}
                            type="button"
                            onClick={() =>
                              setSelectedColIds((prev) =>
                                isSelected
                                  ? prev.filter((id) => id !== col.id)
                                  : [...prev, col.id],
                              )
                            }
                            className={`px-3 py-1.5 rounded-pill text-body-sm transition-all flex items-center gap-1.5 cursor-pointer ${
                              isSelected
                                ? "bg-ink text-eggshell font-medium"
                                : "bg-eggshell text-smoke border border-stone hover:border-graphite/40"
                            }`}
                          >
                            <span>{isSelected ? "✓ " : "+ "}</span>
                            <span>{col.name}</span>
                            {isAiSuggested && (
                              <span
                                className={`text-caption px-1.5 py-0.2 rounded-pill font-medium ${
                                  isSelected
                                    ? "bg-white/20 text-white"
                                    : "bg-amber-500/15 text-amber-600 dark:text-amber-400"
                                }`}
                                title={t("aiBadgeTooltip")}
                              >
                                {t("aiBadge")}
                              </span>
                            )}
                          </button>
                        );
                      })}
                    </div>
                  ) : (
                    !isCreatingCol && (
                      <p className="text-caption text-ash italic">
                        {t("noCollections")}
                      </p>
                    )
                  )}

                  {/* AI Suggested Collections that don't exist yet */}
                  {lookupResult?.suggested_collections?.filter(
                    (sName) =>
                      !collections.some(
                        (c) =>
                          c.name.toLowerCase() === sName.trim().toLowerCase(),
                      ),
                  )?.length > 0 && (
                    <div className="pt-2 border-t border-stone/60 flex flex-col gap-1.5">
                      <span className="text-caption text-smoke flex items-center gap-1">
                        <span>{t("aiSuggestionsTitle")}</span>
                        <span className="text-ash">{t("clickToCreate")}</span>
                      </span>
                      <div className="flex flex-wrap gap-1.5">
                        {lookupResult.suggested_collections
                          .filter(
                            (sName) =>
                              !collections.some(
                                (c) =>
                                  c.name.toLowerCase() ===
                                  sName.trim().toLowerCase(),
                              ),
                          )
                          .map((sName) => (
                            <button
                              key={sName}
                              type="button"
                              onClick={() => handleCreateFromSuggestion(sName)}
                              disabled={isSubmittingCol}
                              className="px-2.5 py-1 rounded-pill text-caption bg-amber-500/10 text-amber-700 dark:text-amber-300 border border-amber-500/30 hover:bg-amber-500/20 transition-all flex items-center gap-1 cursor-pointer"
                            >
                              <span>+ ✨ {sName}</span>
                            </button>
                          ))}
                      </div>
                    </div>
                  )}
                </div>

            {/* Save */}
            <div className="flex justify-end gap-3 pt-4 border-t border-stone">
              <Button
                variant="secondary"
                onClick={() => navigate("/vocabulary")}
              >
                {t("cancel")}
              </Button>
              <Button
                onClick={handleSave}
                disabled={
                  isSaving || Object.keys(selectedMeanings).length === 0
                }
              >
                {isSaving
                  ? t("saving")
                  : t("saveCount", { count: Object.keys(selectedMeanings).length })}
              </Button>
            </div>
          </div>
        )}
          </>
        )}
      </div>
    </>
  );
}
