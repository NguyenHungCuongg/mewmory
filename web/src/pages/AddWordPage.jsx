import { useState, useEffect } from "react";
import { useNavigate, useSearchParams } from "react-router-dom";
import { useTranslation } from "react-i18next";
import { useAuthStore } from "../stores/auth.store";
import { useCollectionStore } from "../stores/collection.store";
import { useSettingsStore } from "../stores/settings.store";
import { useOnlineStatus } from "../hooks/useOnlineStatus";
import { useWordLookup } from "../hooks/useWordLookup";
import { useWordSave } from "../hooks/useWordSave";
import Header from "../components/layout/Header";
import Button from "../components/common/Button";
import Input from "../components/common/Input";
import LoadingSpinner from "../components/common/LoadingSpinner";
import LookupResult from "../components/vocabulary/LookupResult";
import MeaningSelector from "../components/vocabulary/MeaningSelector";
import DuplicateWarning from "../components/vocabulary/DuplicateWarning";
import RateLimitBadge from "../components/vocabulary/RateLimitBadge";
import WordForm from "../components/vocabulary/WordForm";
import CollectionSelector from "../components/vocabulary/CollectionSelector";
import { IconLightning, IconEdit } from "../components/common/Icons";

export default function AddWordPage() {
  const { t } = useTranslation(["addWord", "wordForm"]);
  const navigate = useNavigate();
  const [searchParams] = useSearchParams();
  const defaultColId = searchParams.get("collectionId");

  const { user } = useAuthStore();
  const { settings, fetchSettings } = useSettingsStore();
  const { items: collections, fetchCollections } = useCollectionStore();
  const { isOnline } = useOnlineStatus();

  const [mode, setMode] = useState("auto"); // "auto" | "manual"
  const [selectedColIds, setSelectedColIds] = useState(
    defaultColId ? [defaultColId] : [],
  );

  useEffect(() => {
    if (user?.id && !settings) {
      fetchSettings(user.id);
    }
  }, [user, settings, fetchSettings]);

  useEffect(() => {
    if (user) {
      fetchCollections(user.id);
    }
  }, [user, fetchCollections]);

  // Word save logic & selected meanings
  const {
    selectedMeanings,
    setSelectedMeanings,
    isSaving,
    autoSelectAllMeanings,
    handleSave,
    handleManualSave,
  } = useWordSave({ defaultColId });

  // Word lookup logic & related states
  const {
    word,
    setWord,
    wordError,
    lookupResult,
    setLookupResult,
    isLooking,
    editFields,
    setEditFields,
    rateLimit,
    duplicateCount,
    handleLookup,
    handlePlayAudio,
  } = useWordLookup({ onLookupSuccess: autoSelectAllMeanings });

  const handleKeyDown = (e) => {
    if (e.key === "Enter") {
      e.preventDefault();
      if (!isLooking && !rateLimit.isCoolingDown && !rateLimit.isRateLimited) {
        handleLookup();
      }
    }
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
            <IconLightning className="w-4 h-4 text-current" />
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
            <IconEdit className="w-4 h-4 text-current" />
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
            <div className="flex flex-col gap-2 mb-4">
              <div className="flex gap-3">
                <Input
                  id="word-input"
                  placeholder={t("searchPlaceholder")}
                  value={word}
                  onChange={(e) => setWord(e.target.value)}
                  onKeyDown={handleKeyDown}
                  error={wordError}
                  className="flex-1"
                />
                <Button
                  onClick={() => handleLookup()}
                  disabled={
                    isLooking ||
                    rateLimit.isCoolingDown ||
                    rateLimit.isRateLimited ||
                    !isOnline
                  }
                  title={
                    rateLimit.isRateLimited
                      ? t("rateLimit.exhaustedTooltip", {
                          max: rateLimit.maxRequests,
                          seconds: rateLimit.resetInSeconds,
                        })
                      : undefined
                  }
                >
                  {isLooking ? (
                    <LoadingSpinner size="sm" />
                  ) : rateLimit.isRateLimited && rateLimit.resetInSeconds > 0 ? (
                    `${t("lookupButton")} (${rateLimit.resetInSeconds}s)`
                  ) : (
                    t("lookupButton")
                  )}
                </Button>
              </div>

              {/* Rate Limit Awareness */}
              <div className="flex items-center justify-between px-0.5">
                <RateLimitBadge
                  remainingRequests={rateLimit.remainingRequests}
                  maxRequests={rateLimit.maxRequests}
                  isRateLimited={rateLimit.isRateLimited}
                  isCoolingDown={rateLimit.isCoolingDown}
                  resetInSeconds={rateLimit.resetInSeconds}
                />
              </div>
            </div>

            {/* Duplicate warning */}
            <DuplicateWarning count={duplicateCount} />

            {/* Offline notice */}
            {!isOnline && (
              <div className="mt-4 p-4 bg-amber-50 border border-amber-200 dark:bg-amber-950/70 dark:text-amber-300 dark:border-amber-800 rounded-card text-body-sm text-amber-800 flex items-center justify-between gap-4">
                <div>
                  <p className="font-medium">{t("offlineTitle")}</p>
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
                <CollectionSelector
                  collections={collections}
                  selectedColIds={selectedColIds}
                  onChangeSelectedColIds={setSelectedColIds}
                  suggestedCollections={lookupResult.suggested_collections}
                />

                {/* Save */}
                <div className="flex justify-end gap-3 pt-4 border-t border-stone">
                  <Button
                    variant="secondary"
                    onClick={() => navigate("/vocabulary")}
                  >
                    {t("cancel")}
                  </Button>
                  <Button
                    onClick={() =>
                      handleSave({
                        lookupResult,
                        editFields,
                        selectedColIds,
                        word,
                      })
                    }
                    disabled={
                      isSaving || Object.keys(selectedMeanings).length === 0
                    }
                  >
                    {isSaving
                      ? t("saving")
                      : t("saveCount", {
                          count: Object.keys(selectedMeanings).length,
                        })}
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
