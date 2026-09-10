import { useTranslation } from "react-i18next";

export default function DuplicateWarning({ count, onViewExisting }) {
  const { t } = useTranslation("addWord");
  if (!count || count === 0) return null;

  const unit =
    count === 1
      ? t("duplicateWarning.singular", { defaultValue: "bản ghi" })
      : t("duplicateWarning.plural", { defaultValue: "bản ghi" });

  return (
    <div className="flex items-center gap-2 px-3 py-2 bg-amber-50 border border-amber-200 rounded-lg text-body-sm text-amber-800">
      <span>⚠️</span>
      <span>
        {t("duplicateWarning.prefix", { defaultValue: "Từ này đã có" })}{" "}
        <strong>{count}</strong> {unit}
      </span>
      {onViewExisting && (
        <button
          onClick={onViewExisting}
          className="ml-auto text-amber-900 underline hover:no-underline"
        >
          {t("duplicateWarning.view", { defaultValue: "Xem" })}
        </button>
      )}
    </div>
  );
}
