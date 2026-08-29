export default function LoadingSpinner({ size = "md" }) {
  const sizeClasses = {
    sm: "w-4 h-4",
    md: "w-6 h-6",
    lg: "w-10 h-10",
  };

  return (
    <div
      className={`${sizeClasses[size]} animate-spin rounded-full border-2 border-stone border-t-ink`}
    />
  );
}
