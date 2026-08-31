import { useState, useEffect, useCallback, useRef } from "react";
import { useOnlineStatus } from "./useOnlineStatus";
import { useAuthStore } from "../stores/auth.store";
import { syncEngine } from "../db/sync";

export function useSync() {
  const { isOnline } = useOnlineStatus();
  const { user } = useAuthStore();

  const [isSyncing, setIsSyncing] = useState(false);
  const [lastSyncAt, setLastSyncAt] = useState(() => {
    return user ? localStorage.getItem(`last_sync_${user.id}`) : null;
  });
  const [syncErrors, setSyncErrors] = useState([]);
  const prevOnlineRef = useRef(isOnline);

  const triggerSync = useCallback(async () => {
    if (!user || !isOnline || isSyncing) return;

    setIsSyncing(true);
    setSyncErrors([]);

    try {
      const result = await syncEngine.fullSync(user.id);
      const timestamp = new Date().toISOString();
      setLastSyncAt(timestamp);
      if (result.errors && result.errors.length > 0) {
        setSyncErrors(result.errors);
      }
    } catch (err) {
      console.error("Auto sync failed:", err);
      setSyncErrors([err.message]);
    } finally {
      setIsSyncing(false);
    }
  }, [user, isOnline, isSyncing]);

  // Sync on login / user change
  useEffect(() => {
    if (user && isOnline) {
      triggerSync();
    }
  }, [user?.id]);

  // Sync when coming back online
  useEffect(() => {
    if (!prevOnlineRef.current && isOnline && user) {
      triggerSync();
    }
    prevOnlineRef.current = isOnline;
  }, [isOnline, user, triggerSync]);

  return {
    isSyncing,
    lastSyncAt,
    syncErrors,
    triggerSync,
  };
}
