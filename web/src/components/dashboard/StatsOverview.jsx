import { Link } from "react-router-dom";
import { useTranslation } from "react-i18next";

export default function StatsOverview({ totalVocab, totalCollections, newThisWeek }) {
  const { t } = useTranslation("dashboard");

  return (
    <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
      <Link
        to="/vocabulary"
        className="card-taupe p-5 rounded-card flex flex-col justify-between hover:border-graphite/20 transition-all"
      >
        <span className="text-body-sm text-smoke font-medium">
          {t("stats.totalVocab")}
        </span>
        <div className="flex items-baseline justify-between mt-3">
          <span className="text-heading font-display font-light text-ink">
            {totalVocab}
          </span>
          <span className="text-caption text-ash">{t("stats.viewAll")}</span>
        </div>
      </Link>

      <Link
        to="/collections"
        className="card-taupe p-5 rounded-card flex flex-col justify-between hover:border-graphite/20 transition-all"
      >
        <span className="text-body-sm text-smoke font-medium">
          {t("stats.collections")}
        </span>
        <div className="flex items-baseline justify-between mt-3">
          <span className="text-heading font-display font-light text-ink">
            {totalCollections}
          </span>
          <span className="text-caption text-ash">{t("stats.manage")}</span>
        </div>
      </Link>

      <div className="card-taupe p-5 rounded-card flex flex-col justify-between">
        <span className="text-body-sm text-smoke font-medium">
          {t("stats.newThisWeek")}
        </span>
        <div className="flex items-baseline justify-between mt-3">
          <span className="text-heading font-display font-light text-ink">
            {newThisWeek}
          </span>
          <span className="text-caption text-green-700 font-medium">
            {t("stats.learning")}
          </span>
        </div>
      </div>
    </div>
  );
}

