import { useEffect } from "react";

export default function Toast({
  message,
  type = "success",
  onClose,
  duration = 3000,
}) {
  useEffect(() => {
    const timer = setTimeout(onClose, duration);
    return () => clearTimeout(timer);
  }, [onClose, duration]);

  const typeStyles = {
    success: "bg-green-50 text-green-800 border-green-200",
    error: "bg-red-50 text-red-800 border-red-200",
    info: "bg-blue-50 text-blue-800 border-blue-200",
  };

  return (
    <div
      className={`fixed top-4 right-4 z-50 px-4 py-3 rounded-card border shadow-subtle text-body-sm font-body animate-slide-in ${typeStyles[type]}`}
    >
      <div className="flex items-center gap-2">
        <span>{message}</span>
        <button
          onClick={onClose}
          className="text-current opacity-60 hover:opacity-100 ml-2"
        >
          ✕
        </button>
      </div>
    </div>
  );
}
