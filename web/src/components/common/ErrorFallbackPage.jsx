import { useState } from "react";
import { useTranslation } from "react-i18next";
import Button from "./Button";

export default function ErrorFallbackPage({
  error,
  errorInfo,
  resetErrorBoundary,
}) {
  const { t } = useTranslation("common");
  const [copied, setCopied] = useState(false);

  // Safe translation helper with fallback
  const safeT = (key, fallback) => {
    try {
      const translated = t(key);
      return translated && translated !== key ? translated : fallback;
    } catch {
      return fallback;
    }
  };

  const handleCopyDetails = async () => {
    const errorDetails = [
      `Mewmory Error Report`,
      `Time: ${new Date().toISOString()}`,
      `URL: ${window.location.href}`,
      `Error: ${error?.toString() || "Unknown error"}`,
      error?.stack ? `Stack:\n${error.stack}` : "",
      errorInfo?.componentStack
        ? `Component Stack:\n${errorInfo.componentStack}`
        : "",
    ]
      .filter(Boolean)
      .join("\n\n");

    try {
      if (navigator.clipboard?.writeText) {
        await navigator.clipboard.writeText(errorDetails);
        setCopied(true);
        setTimeout(() => setCopied(false), 2500);
      }
    } catch {
      // Ignore copy error
    }
  };

  const handleReload = () => {
    window.location.reload();
  };

  const handleGoHome = () => {
    window.location.href = "/";
  };

  return (
    <div
      role="alert"
      className="min-h-screen bg-eggshell text-ink flex items-center justify-center p-4 sm:p-6 transition-colors duration-200"
    >
      <div className="w-full max-w-lg bg-warm-taupe border border-stone rounded-card p-6 sm:p-8 shadow-subtle text-center animate-fade-in">
        {/* Mewmory Logo */}
        <div className="w-16 h-16 sm:w-20 sm:h-20 mx-auto mb-5 flex items-center justify-center">
          <img
            src="/mewmory_icon_192.png"
            alt="Mewmory Logo"
            className="w-16 h-16 sm:w-20 sm:h-20 rounded-2xl shadow-subtle object-contain"
          />
        </div>

        {/* Headings */}
        <h1 className="text-xl sm:text-2xl font-display font-light text-ink tracking-tight mb-2">
          {safeT("errorBoundary.title", "Đã xảy ra sự cố ngoài ý muốn")}
        </h1>
        <p className="text-body-sm text-smoke leading-relaxed mb-6">
          {safeT(
            "errorBoundary.subtitle",
            "Mewmory gặp lỗi trong quá trình hiển thị giao diện. Đừng lo, dữ liệu từ vựng và tiến độ học của bạn vẫn an toàn trong máy.",
          )}
        </p>

        {/* Action Buttons */}
        <div className="flex flex-wrap items-center justify-center gap-3 mb-6">
          {resetErrorBoundary && (
            <Button
              variant="primary"
              onClick={resetErrorBoundary}
              className="px-5"
            >
              {safeT("errorBoundary.tryAgain", "Thử lại")}
            </Button>
          )}

          <Button
            variant="secondary"
            onClick={handleReload}
            className="px-5"
          >
            {safeT("errorBoundary.reloadPage", "Tải lại trang")}
          </Button>

          <Button
            variant="ghost"
            onClick={handleGoHome}
            className="px-4"
          >
            {safeT("errorBoundary.goHome", "Về trang chủ")}
          </Button>
        </div>

        {/* Collapsible Technical Details */}
        {error && (
          <details className="text-left border-t border-stone pt-4 mt-4 group">
            <summary className="text-caption text-ash hover:text-smoke cursor-pointer select-none font-mono flex items-center justify-between">
              <span>{safeT("errorBoundary.showDetails", "Chi tiết kỹ thuật")}</span>
              <span className="text-xs group-open:rotate-180 transition-transform">▼</span>
            </summary>

            <div className="mt-3 p-3 rounded-md bg-eggshell border border-stone font-mono text-xs text-graphite overflow-x-auto max-h-48">
              <div className="text-ember-orange font-medium mb-1 break-words">
                {error.name}: {error.message}
              </div>
              {error.stack && (
                <pre className="whitespace-pre-wrap text-[11px] text-smoke leading-snug">
                  {error.stack}
                </pre>
              )}
            </div>

            <div className="mt-2 text-right">
              <button
                type="button"
                onClick={handleCopyDetails}
                className="text-xs font-mono text-ash hover:text-ink transition-colors underline cursor-pointer"
              >
                {copied
                  ? safeT("errorBoundary.copied", "Đã sao chép!")
                  : safeT("errorBoundary.copyDetails", "Sao chép mã lỗi")}
              </button>
            </div>
          </details>
        )}
      </div>
    </div>
  );
}
