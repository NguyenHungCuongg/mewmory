import { useTranslation } from "react-i18next";
import { IconAlert } from "../common/Icons";

export default function DuplicateWarning({ count, onViewExisting }) {
  const { t } = useTranslation("addWord");
  if (!count || count === 0) return null;

  const unit =
    count === 1
      ? t("duplicateWarning.singular", { defaultValue: "bản ghi" })
      : t("duplicateWarning.plural", { defaultValue: "bản ghi" });

  return (
    <div className="flex items-center gap-2 px-3 py-2 bg-warm-taupe border border-stone rounded-lg text-body-sm text-graphite">
      <IconAlert className="w-4 h-4 shrink-0 text-smoke" />
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
