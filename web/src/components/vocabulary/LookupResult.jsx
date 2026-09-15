import { useTranslation } from "react-i18next";
import { IconVolume } from "../common/Icons";

export default function LookupResult({ result, onPlayAudio }) {
  const { t } = useTranslation("addWord");
  if (!result) return null;

  return (
    <div className="flex items-center gap-4 p-4 bg-warm-taupe rounded-card">
      <div className="flex-1">
        <div className="flex items-center gap-3">
          <h3 className="text-heading-sm font-display font-light">
            {result.word}
          </h3>
          {(result.audio_url || result.word) && (
            <button
              type="button"
              onClick={() => onPlayAudio(result.audio_url, result.word)}
              className="w-8 h-8 rounded-full bg-eggshell border border-stone flex items-center justify-center hover:bg-stone/50 transition-colors cursor-pointer"
              title={t("lookupResult.pronounce", { defaultValue: "Phát âm" })}
              aria-label={t("lookupResult.pronounce", { defaultValue: "Phát âm" })}
            >
              <IconVolume className="w-4 h-4 text-graphite" />
            </button>
          )}
        </div>
        {result.phonetic && (
          <p className="text-body text-smoke font-mono mt-1">
            {result.phonetic}
          </p>
        )}
      </div>
      <div className="flex items-center gap-1.5">
        {result.source?.dictionary && (
          <span className="px-2 py-0.5 bg-eggshell text-smoke border border-stone rounded-md text-caption font-mono uppercase tracking-wider">
            {t("lookupResult.dictionary", { defaultValue: "Dictionary" })}
          </span>
        )}
        {result.source?.ai && (
          <span className="px-2 py-0.5 bg-eggshell text-smoke border border-stone rounded-md text-caption font-mono uppercase tracking-wider">
            {t("lookupResult.ai", { defaultValue: "AI" })}
          </span>
        )}
      </div>
    </div>
  );
}
