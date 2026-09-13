import { useEffect } from "react";

export default function Modal({ isOpen, onClose, title, children }) {
  useEffect(() => {
    if (isOpen) {
      document.body.style.overflow = "hidden";
    } else {
      document.body.style.overflow = "";
    }
    return () => {
      document.body.style.overflow = "";
    };
  }, [isOpen]);

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center">
      <div
        className="absolute inset-0 bg-black/40 dark:bg-black/70 backdrop-blur-sm"
        onClick={onClose}
      />
      <div className="relative bg-eggshell border border-stone/60 rounded-card-lg p-6 w-full max-w-lg mx-4 shadow-subtle animate-fade-in">
        {title && (
          <h2 className="text-heading-sm font-display font-light mb-4">
            {title}
          </h2>
        )}
        {children}
      </div>
    </div>
  );
}
