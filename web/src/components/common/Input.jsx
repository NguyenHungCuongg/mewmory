export default function Input({ label, error, id, className = "", ...props }) {
  return (
    <div className={`flex flex-col gap-1.5 ${className}`}>
      {label && (
        <label htmlFor={id} className="text-body-sm text-graphite font-medium">
          {label}
        </label>
      )}
      <input
        id={id}
        className={`w-full px-3 py-2 rounded border bg-eggshell text-ink text-body font-body placeholder:text-ash focus:outline-none focus:ring-1 transition-colors ${
          error
            ? "border-red-400 focus:ring-red-400"
            : "border-stone focus:ring-ink"
        }`}
        {...props}
      />
      {error && <p className="text-body-sm text-red-500">{error}</p>}
    </div>
  );
}
