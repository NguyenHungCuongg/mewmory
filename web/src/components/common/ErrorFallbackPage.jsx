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
        {/* Cat Illustration Icon */}
        <div className="w-16 h-16 sm:w-20 sm:h-20 mx-auto mb-5 rounded-full bg-stone/50 flex items-center justify-center text-graphite">
          <svg
            className="w-10 h-10 sm:w-12 sm:h-12"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            strokeWidth="1.5"
            strokeLinecap="round"
            strokeLinejoin="round"
          >
            {/* Cute cat with sad/surprised face */}
            <path d="M12 5c.67 0 1.35.09 2 .26 1.78-2 3.5-1.76 4.5-.5.5 1.5.2 3.2-.5 4.5 1.25 1.63 1.8 3.5 1.5 5.5-.5 3-3 5-7.5 5s-7-2-7.5-5c-.3-2 .25-3.87 1.5-5.5-.7-1.3-1-3-.5-4.5 1-1.26 2.72-1.5 4.5.5.65-.17 1.33-.26 2-.26z" />
            <circle cx="9.5" cy="13.5" r="1" fill="currentColor" />
            <circle cx="14.5" cy="13.5" r="1" fill="currentColor" />
            <path d="M11 16.5c.5-.5 1.5-.5 2 0" />
            <path d="M5 14h2M17 14h2" />
          </svg>
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
