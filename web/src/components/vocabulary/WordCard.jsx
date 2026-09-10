import { Link } from "react-router-dom";
import { useTranslation } from "react-i18next";
import { CEFR_COLORS } from "../../utils/constants";

export default function WordCard({ vocabulary }) {
  const { t } = useTranslation("vocabulary");
  const cefrStyle = CEFR_COLORS[vocabulary.cefr_level] || {};
  const firstDef = vocabulary.definitions?.[0];
  const extraDefsCount = (vocabulary.definitions?.length || 1) - 1;

  return (
    <Link
      to={`/vocabulary/${vocabulary.id}`}
      className="group relative flex flex-col justify-between p-5 rounded-card bg-warm-taupe border border-stone shadow-[0_1px_3px_rgba(0,0,0,0.03)] hover:shadow-[0_8px_20px_rgba(0,0,0,0.06)] hover:border-graphite/40 hover:-translate-y-0.5 transition-all duration-200"
    >
      <div>
        {/* Top row: Word and Badges */}
        <div className="flex items-start justify-between gap-2 mb-1">
          <div className="min-w-0 flex-1">
            <h3 className="text-xl font-medium text-ink tracking-tight group-hover:text-black transition-colors truncate">
              {vocabulary.word}
            </h3>
            {vocabulary.phonetic && (
              <p className="text-body-sm text-smoke font-mono mt-0.5 tracking-wide">
                {vocabulary.phonetic}
              </p>
            )}
          </div>

          <div className="flex items-center gap-1.5 shrink-0 pt-0.5">
            {vocabulary.part_of_speech && (
              <span className="px-2.5 py-0.5 bg-eggshell border border-stone rounded-pill text-caption text-graphite font-medium shadow-2xs">
                {vocabulary.part_of_speech}
              </span>
            )}
            {vocabulary.cefr_level && (
              <span
                className={`px-2 py-0.5 rounded-pill text-caption font-semibold border border-black/5 ${cefrStyle.bg || "bg-stone"} ${cefrStyle.text || "text-graphite"}`}
              >
                {vocabulary.cefr_level}
              </span>
            )}
          </div>
        </div>

        {/* Hairline Divider */}
        <div className="h-px bg-stone/70 my-3 group-hover:bg-stone transition-colors" />

        {/* Definitions & Examples */}
        <div className="flex flex-col gap-1.5 min-h-[50px]">
          {firstDef?.definition_vi ? (
            <>
              <p className="text-body-sm font-medium text-ink leading-snug line-clamp-2">
                {firstDef.definition_vi}
              </p>
              {firstDef?.definition_en && (
                <p className="text-caption text-smoke line-clamp-1">
                  {firstDef.definition_en}
                </p>
              )}
            </>
          ) : firstDef?.definition_en ? (
            <p className="text-body-sm text-graphite leading-snug line-clamp-2">
              {firstDef.definition_en}
            </p>
          ) : (
            <p className="text-caption text-ash italic">
              {t("card.noDefinition")}
            </p>
          )}

          {firstDef?.example && (
            <p className="text-caption text-ash italic border-l-2 border-stone pl-2 mt-1 line-clamp-1">
              "{firstDef.example}"
            </p>
          )}
        </div>
      </div>

      {/* Card Footer: Metadata & hover prompt */}
      <div className="flex items-center justify-between mt-3 pt-2.5 border-t border-stone/50 text-caption text-smoke">
        <span>
          {extraDefsCount > 0
            ? t("card.extraDefs", { count: extraDefsCount })
            : t("card.details")}
        </span>
        <span className="text-smoke group-hover:text-ink group-hover:translate-x-0.5 transition-all font-medium">
          {t("card.viewWord")}
        </span>
      </div>
    </Link>
  );
}

