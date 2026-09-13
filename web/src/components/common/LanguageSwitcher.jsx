import { useTranslation } from "react-i18next";

export default function LanguageSwitcher() {
  const { i18n, t } = useTranslation("common");

  const currentLang = (i18n.resolvedLanguage || i18n.language || "vi").startsWith("en")
    ? "en"
    : "vi";

  const toggleLanguage = () => {
    const nextLang = currentLang === "vi" ? "en" : "vi";
    i18n.changeLanguage(nextLang);
  };

  return (
    <button
      type="button"
      onClick={toggleLanguage}
      title={t("language")}
      aria-label={t("language")}
      className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-lg border border-stone bg-eggshell hover:bg-warm-taupe text-smoke hover:text-ink text-body-sm transition-colors cursor-pointer shadow-subtle-inset"
    >
      <span className="text-xs font-semibold uppercase tracking-wider text-graphite">
        {currentLang === "vi" ? "VI" : "EN"}
      </span>
      <span className="text-caption text-ash">/</span>
      <span className="text-caption text-smoke hover:text-ink">
        {currentLang === "vi" ? "EN" : "VI"}
      </span>
    </button>
  );
}
