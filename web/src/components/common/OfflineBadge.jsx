import { useOnlineStatus } from "../../hooks/useOnlineStatus";

export default function OfflineBadge() {
  const { isOnline } = useOnlineStatus();

  if (isOnline) return null;

  return (
    <div className="inline-flex items-center gap-1.5 px-3 py-1 bg-amber-50 text-amber-700 border border-amber-200 rounded-pill text-body-sm">
      <span className="w-2 h-2 rounded-full bg-amber-500 animate-pulse" />
      Offline
    </div>
  );
}
