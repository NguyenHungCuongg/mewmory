import { useState, useEffect, useCallback, useRef } from "react";

/**
 * Custom hook providing click debounce protection and sliding-window rate limit awareness.
 *
 * @param {Object} options
 * @param {number} [options.maxRequests=15] - Maximum allowed requests in the time window (e.g. 15 RPM for Gemini Free)
 * @param {number} [options.windowMs=60000] - Sliding window duration in milliseconds (default: 60s)
 * @param {number} [options.cooldownMs=2000] - Debounce/cooldown lock duration between clicks (default: 2000ms)
 * @param {string} [options.storageKey="mewmory_lookup_ratelimit"] - Key for sessionStorage persistence
 */
export function useRateLimit({
  maxRequests = 15,
  windowMs = 60000,
  cooldownMs = 2000,
  storageKey = "mewmory_lookup_ratelimit",
} = {}) {
  // Helper to load stored timestamps safely from sessionStorage
  const getStoredTimestamps = useCallback(() => {
    try {
      if (typeof window !== "undefined" && window.sessionStorage) {
        const raw = window.sessionStorage.getItem(storageKey);
        if (raw) {
          const parsed = JSON.parse(raw);
          const now = Date.now();
          // Filter out timestamps outside the window
          return Array.isArray(parsed)
            ? parsed.filter((t) => typeof t === "number" && now - t < windowMs)
            : [];
        }
      }
    } catch {
      // Fallback if sessionStorage unavailable
    }
    return [];
  }, [storageKey, windowMs]);

  // Save timestamps to sessionStorage
  const saveStoredTimestamps = useCallback(
    (timestamps) => {
      try {
        if (typeof window !== "undefined" && window.sessionStorage) {
          window.sessionStorage.setItem(storageKey, JSON.stringify(timestamps));
        }
      } catch {
        // Ignore storage write errors
      }
    },
    [storageKey],
  );

  const [timestamps, setTimestamps] = useState(getStoredTimestamps);
  const [isCoolingDown, setIsCoolingDown] = useState(false);
  const [extendedCooldownUntil, setExtendedCooldownUntil] = useState(0);
  const [, setTick] = useState(0);
  const cooldownTimerRef = useRef(null);

  // Compute current time & valid timestamps within current sliding window
  const now = Date.now();
  const validTimestamps = timestamps.filter((t) => now - t < windowMs);
  const requestCount = validTimestamps.length;
  const remainingRequests = Math.max(0, maxRequests - requestCount);

  // Determine if rate-limited by sliding window or by extended cooldown (e.g. 429)
  const isWindowExhausted = remainingRequests <= 0;
  const isExtendedCooling = extendedCooldownUntil > now;
  const isRateLimited = isWindowExhausted || isExtendedCooling;

  // Calculate seconds until reset
  let resetInSeconds = 0;
  if (isExtendedCooling) {
    resetInSeconds = Math.max(1, Math.ceil((extendedCooldownUntil - now) / 1000));
  } else if (isWindowExhausted && validTimestamps.length > 0) {
    const oldestTimestamp = Math.min(...validTimestamps);
    resetInSeconds = Math.max(
      1,
      Math.ceil((oldestTimestamp + windowMs - now) / 1000),
    );
  }

  // Periodic tick to clean expired timestamps and update live countdowns
  useEffect(() => {
    const interval = setInterval(() => {
      const currentTime = Date.now();
      setTick((t) => t + 1);

      setTimestamps((prev) => {
        const filtered = prev.filter((t) => currentTime - t < windowMs);
        if (filtered.length !== prev.length) {
          saveStoredTimestamps(filtered);
          return filtered;
        }
        return prev;
      });
    }, 1000);

    return () => clearInterval(interval);
  }, [windowMs, saveStoredTimestamps]);

  // Cleanup cooldown timer on unmount
  useEffect(() => {
    return () => {
      if (cooldownTimerRef.current) {
        clearTimeout(cooldownTimerRef.current);
      }
    };
  }, []);

  /**
   * Check if a new request can be executed right now
   */
  const canExecute = useCallback(() => {
    const currentNow = Date.now();
    if (isCoolingDown) {
      return {
        allowed: false,
        reason: "cooling_down",
        message: "Vui lòng đợi giây lát giữa các lần bấm.",
      };
    }

    if (extendedCooldownUntil > currentNow) {
      const waitSec = Math.ceil((extendedCooldownUntil - currentNow) / 1000);
      return {
        allowed: false,
        reason: "extended_cooldown",
        waitSeconds: waitSec,
        message: `Đang trong thời gian chờ tạm thời. Vui lòng thử lại sau ${waitSec}s.`,
      };
    }

    const currentValid = timestamps.filter((t) => currentNow - t < windowMs);
    if (currentValid.length >= maxRequests) {
      const oldest = Math.min(...currentValid);
      const waitSec = Math.max(1, Math.ceil((oldest + windowMs - currentNow) / 1000));
      return {
        allowed: false,
        reason: "rate_limited",
        waitSeconds: waitSec,
        message: `Đã đạt giới hạn ${maxRequests} lượt/phút. Vui lòng thử lại sau ${waitSec}s.`,
      };
    }

    return { allowed: true };
  }, [isCoolingDown, extendedCooldownUntil, timestamps, windowMs, maxRequests]);

  /**
   * Record a new request: registers timestamp & starts rapid click debounce cooldown
   */
  const recordRequest = useCallback(() => {
    const currentNow = Date.now();

    // 1. Activate debounce lock immediately
    setIsCoolingDown(true);
    if (cooldownTimerRef.current) {
      clearTimeout(cooldownTimerRef.current);
    }
    cooldownTimerRef.current = setTimeout(() => {
      setIsCoolingDown(false);
    }, cooldownMs);

    // 2. Add timestamp to sliding window and save
    setTimestamps((prev) => {
      const updated = [...prev.filter((t) => currentNow - t < windowMs), currentNow];
      saveStoredTimestamps(updated);
      return updated;
    });
  }, [cooldownMs, windowMs, saveStoredTimestamps]);

  /**
   * Trigger an extended cooldown (e.g. when 429 Too Many Requests is received from server)
   * @param {number} [seconds=30] - Seconds to wait
   */
  const triggerCooldown = useCallback((seconds = 30) => {
    const until = Date.now() + seconds * 1000;
    setExtendedCooldownUntil(until);
  }, []);

  /**
   * Reset rate limit state manually (useful for testing or cache clears)
   */
  const resetRateLimit = useCallback(() => {
    setTimestamps([]);
    setIsCoolingDown(false);
    setExtendedCooldownUntil(0);
    saveStoredTimestamps([]);
  }, [saveStoredTimestamps]);

  return {
    isCoolingDown,
    isRateLimited,
    isWindowExhausted,
    remainingRequests,
    maxRequests,
    requestCount,
    resetInSeconds,
    canExecute,
    recordRequest,
    triggerCooldown,
    resetRateLimit,
  };
}
