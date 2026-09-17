import { useState } from "react";
import { useTranslation } from "react-i18next";
import { useAuthStore } from "../../stores/auth.store";
import { useCollectionStore } from "../../stores/collection.store";
import { useUIStore } from "../../stores/ui.store";
import Button from "../common/Button";

export default function CollectionSelector({
  collections = [],
  selectedColIds = [],
  onChangeSelectedColIds,
  suggestedCollections = [],
}) {
  const { t } = useTranslation("addWord");
  const { user } = useAuthStore();
  const { addCollection } = useCollectionStore();
  const addToast = useUIStore((s) => s.addToast);

  const [isCreatingCol, setIsCreatingCol] = useState(false);
  const [newColName, setNewColName] = useState("");
  const [isSubmittingCol, setIsSubmittingCol] = useState(false);

  const handleToggleCol = (colId) => {
    if (selectedColIds.includes(colId)) {
      onChangeSelectedColIds(selectedColIds.filter((id) => id !== colId));
    } else {
      onChangeSelectedColIds([...selectedColIds, colId]);
    }
  };

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
        onChangeSelectedColIds([...selectedColIds, newCol.id]);
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
        onChangeSelectedColIds([...selectedColIds, newCol.id]);
      }
      addToast(t("toastColCreated", { name: suggestedName }), "success");
    } catch (err) {
      addToast(err.message || t("toastColError"), "error");
    } finally {
      setIsSubmittingCol(false);
    }
  };

  const uncreatedAiSuggestions = suggestedCollections.filter(
    (sName) =>
      !collections.some(
        (c) => c.name.toLowerCase() === sName.trim().toLowerCase(),
      ),
  );

  return (
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
      <p className="text-caption text-smoke">{t("collectionsDesc")}</p>

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
            const isAiSuggested = suggestedCollections.some(
              (sc) => sc.toLowerCase() === col.name.toLowerCase(),
            );

            return (
              <button
                key={col.id}
                type="button"
                onClick={() => handleToggleCol(col.id)}
                className={`px-3 py-1.5 rounded-pill text-body-sm transition-all flex items-center gap-1.5 cursor-pointer ${
                  isSelected
                    ? "bg-ink text-eggshell font-medium"
                    : isAiSuggested
                      ? "bg-eggshell text-ink border border-amber-400/40 hover:border-amber-500/60 shadow-2xs"
                      : "bg-eggshell text-smoke border border-stone hover:border-graphite/40"
                }`}
              >
                <span>{isSelected ? "✓ " : "+ "}</span>
                <span>{col.name}</span>
                {isAiSuggested && (
                  <span
                    className={`text-caption px-1.5 py-0.5 rounded-pill font-mono uppercase tracking-wider text-[10px] font-semibold border transition-colors ${
                      isSelected
                        ? "bg-amber-400/25 text-amber-300 border-amber-300/40 dark:bg-amber-500/20 dark:text-amber-900 dark:border-amber-600/30"
                        : "bg-amber-500/10 text-amber-700 border-amber-500/30 dark:bg-amber-400/15 dark:text-amber-300 dark:border-amber-400/30 shadow-2xs"
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
          <p className="text-caption text-ash italic">{t("noCollections")}</p>
        )
      )}

      {/* AI Suggested Collections that don't exist yet */}
      {uncreatedAiSuggestions.length > 0 && (
        <div className="pt-2 border-t border-stone/60 flex flex-col gap-1.5">
          <span className="text-caption text-smoke flex items-center gap-1">
            <span>{t("aiSuggestionsTitle")}</span>
            <span className="text-ash">{t("clickToCreate")}</span>
          </span>
          <div className="flex flex-wrap gap-1.5">
            {uncreatedAiSuggestions.map((sName) => (
              <button
                key={sName}
                type="button"
                onClick={() => handleCreateFromSuggestion(sName)}
                disabled={isSubmittingCol}
                className="px-2.5 py-1 rounded-pill text-caption bg-eggshell text-smoke border border-stone border-dashed hover:text-ink hover:border-graphite/40 transition-all flex items-center gap-1 cursor-pointer"
              >
                <span>+ {sName}</span>
              </button>
            ))}
          </div>
        </div>
      )}
    </div>
  );
}
