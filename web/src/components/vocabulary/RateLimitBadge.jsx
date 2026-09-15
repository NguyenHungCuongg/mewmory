import { useTranslation } from "react-i18next";

export default function RateLimitBadge({
  remainingRequests,
  maxRequests = 15,
  isRateLimited,
  isCoolingDown,
  resetInSeconds,
  className = "",
}) {
  const { t } = useTranslation("addWord");

  // Warning state when quota is nearly exhausted
  const isWarning = remainingRequests > 0 && remainingRequests <= 3;

  if (isRateLimited) {
    return (
      <div
        data-testid="rate-limit-exhausted"
        className={`inline-flex items-center gap-1.5 px-2.5 py-1 rounded-pill text-xs font-mono bg-ember-orange/10 text-ember-orange border border-ember-orange/30 animate-fade-in ${className}`}
        title={t("rateLimit.exhaustedTooltip", {
          seconds: resetInSeconds,
          defaultValue: `Đã đạt giới hạn ${maxRequests} lượt/phút. Vui lòng đợi ${resetInSeconds}s.`,
        })}
      >
        <span className="inline-block w-1.5 h-1.5 rounded-full bg-ember-orange animate-pulse" />
        <span>
          {t("rateLimit.exhausted", {
            seconds: resetInSeconds,
            defaultValue: `Hết lượt tra cứu (${resetInSeconds}s)`,
          })}
        </span>
      </div>
    );
  }

  if (isCoolingDown) {
    return (
      <div
        data-testid="rate-limit-cooling"
        className={`inline-flex items-center gap-1.5 px-2.5 py-1 rounded-pill text-xs font-mono bg-stone/40 text-smoke border border-stone animate-fade-in ${className}`}
      >
        <span className="inline-block w-1.5 h-1.5 rounded-full bg-smoke animate-ping" />
        <span>
          {t("rateLimit.coolingDown", {
            defaultValue: "Đang sẵn sàng...",
          })}
        </span>
      </div>
    );
  }

  return (
    <div
      data-testid="rate-limit-normal"
      className={`inline-flex items-center gap-1.5 px-2.5 py-1 rounded-pill text-xs font-mono transition-colors duration-200 border ${
        isWarning
          ? "bg-amber-500/10 text-amber-600 dark:text-amber-400 border-amber-500/30"
          : "bg-warm-taupe text-ash border-stone hover:text-smoke"
      } ${className}`}
      title={t("rateLimit.tooltip", {
        defaultValue: `Hạn mức: ${remainingRequests}/${maxRequests} lượt tra cứu trong mỗi phút`,
      })}
    >
      <span
        className={`inline-block w-1.5 h-1.5 rounded-full ${
          isWarning ? "bg-amber-500" : "bg-emerald-500"
        }`}
      />
      <span>
        {t("rateLimit.quota", {
          remaining: remainingRequests,
          max: maxRequests,
          defaultValue: `${remainingRequests}/${maxRequests} lượt/phút`,
        })}
      </span>
      {isWarning && resetInSeconds > 0 && (
        <span className="opacity-80">({resetInSeconds}s)</span>
      )}
    </div>
  );
}
