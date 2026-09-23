export default function StatCard({ label, value, icon, alert = false }) {
  return (
    <div className={`rounded-2xl p-6 border ${alert && value > 0 ? "border-red-500/40 bg-red-950/20" : "border-white/10 bg-white/5"}`}>
      <div className="flex items-center gap-3 mb-2">
        <span className="text-2xl">{icon}</span>
        <span className="text-sm text-gray-400 font-medium">{label}</span>
      </div>
      <div className={`text-3xl font-semibold ${alert && value > 0 ? "text-red-400" : "text-white"}`}>
        {value?.toLocaleString() ?? "—"}
      </div>
    </div>
  );
}
