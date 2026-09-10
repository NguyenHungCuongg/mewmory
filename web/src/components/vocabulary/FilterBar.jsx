import { useTranslation } from "react-i18next";
import {
  CEFR_LEVELS,
  PARTS_OF_SPEECH,
  USAGE_REGISTERS,
} from "../../utils/constants";

export default function FilterBar({ filters, onFilterChange, collections = [] }) {
  const { t } = useTranslation("vocabulary");

  const handleChange = (key, value) => {
    onFilterChange({
      ...filters,
      [key]: value || undefined,
    });
  };

  return (
    <div className="flex flex-wrap items-center gap-3 p-4 card-taupe rounded-card">
      <select
        value={filters.cefr_level || ""}
        onChange={(e) => handleChange("cefr_level", e.target.value)}
        className="px-3 py-1.5 rounded-pill border border-stone bg-eggshell text-body-sm text-graphite focus:outline-none focus:border-ink cursor-pointer"
      >
        <option value="">{t("filter.allCefr")}</option>
        {CEFR_LEVELS.map((l) => (
          <option key={l} value={l}>
            {l}
          </option>
        ))}
      </select>

      <select
        value={filters.part_of_speech || ""}
        onChange={(e) => handleChange("part_of_speech", e.target.value)}
        className="px-3 py-1.5 rounded-pill border border-stone bg-eggshell text-body-sm text-graphite focus:outline-none focus:border-ink cursor-pointer"
      >
        <option value="">{t("filter.allPartsOfSpeech")}</option>
        {PARTS_OF_SPEECH.map((p) => (
          <option key={p} value={p}>
            {p}
          </option>
        ))}
      </select>

      <select
        value={filters.usage_register || ""}
        onChange={(e) => handleChange("usage_register", e.target.value)}
        className="px-3 py-1.5 rounded-pill border border-stone bg-eggshell text-body-sm text-graphite focus:outline-none focus:border-ink cursor-pointer"
      >
        <option value="">{t("filter.allUsageRegisters")}</option>
        {USAGE_REGISTERS.map((u) => (
          <option key={u} value={u}>
            {u}
          </option>
        ))}
      </select>

      {collections.length > 0 && (
        <select
          value={filters.collection_id || ""}
          onChange={(e) => handleChange("collection_id", e.target.value)}
          className="px-3 py-1.5 rounded-pill border border-stone bg-eggshell text-body-sm text-graphite focus:outline-none focus:border-ink cursor-pointer"
        >
          <option value="">{t("filter.allCollections")}</option>
          {collections.map((c) => (
            <option key={c.id} value={c.id}>
              {c.name}
            </option>
          ))}
        </select>
      )}

      {Object.values(filters).some(Boolean) && (
        <button
          onClick={() => onFilterChange({})}
          className="text-caption text-smoke hover:text-ink font-medium px-2 py-1 underline cursor-pointer"
        >
          {t("filter.clear")}
        </button>
      )}
    </div>
  );
}

