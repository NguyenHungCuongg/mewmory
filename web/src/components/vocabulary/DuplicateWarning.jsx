export default function DuplicateWarning({ count, onViewExisting }) {
  if (!count || count === 0) return null;

  return (
    <div className="flex items-center gap-2 px-3 py-2 bg-amber-50 border border-amber-200 rounded-lg text-body-sm text-amber-800">
      <span>⚠️</span>
      <span>
        Từ này đã có <strong>{count}</strong>{" "}
        {count === 1 ? "entry" : "entries"}
      </span>
      {onViewExisting && (
        <button
          onClick={onViewExisting}
          className="ml-auto text-amber-900 underline hover:no-underline"
        >
          Xem
        </button>
      )}
    </div>
  );
}
