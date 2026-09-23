export default function StatCard({ label, value, icon, alert = false, description }) {
  const isAlertActive = alert && value > 0;

  return (
    <div
      className={`rounded-2xl p-5 border transition-all ${
        isAlertActive
          ? "border-amber-500/40 bg-amber-500/5 shadow-lg shadow-amber-500/5"
          : "border-slate-800/80 bg-[#0f1523] hover:border-slate-700/80"
      }`}
    >
      <div className="flex items-center justify-between gap-3 mb-3">
        <span className="text-xs font-medium uppercase tracking-wider text-slate-400">
          {label}
        </span>
        <div
          className={`p-2 rounded-xl border ${
            isAlertActive
              ? "bg-amber-500/10 text-amber-400 border-amber-500/20"
              : "bg-slate-800/60 text-slate-300 border-slate-700/50"
          }`}
        >
          {icon}
        </div>
      </div>

      <div className="flex items-baseline justify-between gap-2">
        <div
          className={`text-3xl font-semibold tracking-tight font-mono tabular-nums ${
            isAlertActive ? "text-amber-300" : "text-white"
          }`}
        >
          {value !== null && value !== undefined ? value.toLocaleString() : "—"}
        </div>
        {isAlertActive && (
          <span className="text-[11px] font-medium px-2 py-0.5 rounded-full bg-amber-500/15 text-amber-400 border border-amber-500/30">
            Cần rà soát
          </span>
        )}
      </div>

      {description && (
        <p className="text-xs text-slate-400 mt-2 font-normal">{description}</p>
      )}
    </div>
  );
}
