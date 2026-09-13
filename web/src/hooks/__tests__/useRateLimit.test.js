import { describe, it, expect, vi, beforeEach, afterEach } from "vitest";
import { renderHook, act } from "@testing-library/react";
import { useRateLimit } from "../useRateLimit";

describe("useRateLimit", () => {
  beforeEach(() => {
    vi.useFakeTimers();
    sessionStorage.clear();
  });

  afterEach(() => {
    vi.restoreAllMocks();
    vi.useRealTimers();
  });

  it("initializes with full quota and not cooling down or rate limited", () => {
    const { result } = renderHook(() =>
      useRateLimit({ maxRequests: 5, windowMs: 10000, cooldownMs: 1000 }),
    );

    expect(result.current.remainingRequests).toBe(5);
    expect(result.current.maxRequests).toBe(5);
    expect(result.current.isRateLimited).toBe(false);
    expect(result.current.isCoolingDown).toBe(false);
    expect(result.current.canExecute().allowed).toBe(true);
  });

  it("prevents double-click by setting isCoolingDown immediately upon recordRequest", () => {
    const { result } = renderHook(() =>
      useRateLimit({ maxRequests: 5, windowMs: 10000, cooldownMs: 1500 }),
    );

    act(() => {
      result.current.recordRequest();
    });

    // Immediately cooling down (debounce lock)
    expect(result.current.isCoolingDown).toBe(true);
    expect(result.current.remainingRequests).toBe(4);
    expect(result.current.canExecute().allowed).toBe(false);
    expect(result.current.canExecute().reason).toBe("cooling_down");

    // Advance by 1000ms (still within 1500ms cooldown)
    act(() => {
      vi.advanceTimersByTime(1000);
    });
    expect(result.current.isCoolingDown).toBe(true);

    // Advance remaining 500ms
    act(() => {
      vi.advanceTimersByTime(500);
    });
    expect(result.current.isCoolingDown).toBe(false);
    expect(result.current.canExecute().allowed).toBe(true);
  });

  it("enforces sliding-window rate limit when quota is reached", () => {
    const { result } = renderHook(() =>
      useRateLimit({ maxRequests: 3, windowMs: 5000, cooldownMs: 200 }),
    );

    // Make 3 requests
    for (let i = 0; i < 3; i++) {
      act(() => {
        result.current.recordRequest();
        vi.advanceTimersByTime(300); // clear debounce lock
      });
    }

    expect(result.current.remainingRequests).toBe(0);
    expect(result.current.isRateLimited).toBe(true);
    expect(result.current.canExecute().allowed).toBe(false);
    expect(result.current.canExecute().reason).toBe("rate_limited");
    expect(result.current.resetInSeconds).toBeGreaterThan(0);

    // Advance timer past the 5000ms sliding window (last request was at 600ms, so 6000ms clears all)
    act(() => {
      vi.advanceTimersByTime(6000);
    });

    expect(result.current.isRateLimited).toBe(false);
    expect(result.current.remainingRequests).toBe(3);
    expect(result.current.canExecute().allowed).toBe(true);
  });

  it("supports triggering extended cooldown when server returns 429", () => {
    const { result } = renderHook(() =>
      useRateLimit({ maxRequests: 10, windowMs: 60000, cooldownMs: 1000 }),
    );

    act(() => {
      result.current.triggerCooldown(20); // 20s cooldown
    });

    expect(result.current.isRateLimited).toBe(true);
    expect(result.current.resetInSeconds).toBe(20);
    expect(result.current.canExecute().allowed).toBe(false);
    expect(result.current.canExecute().reason).toBe("extended_cooldown");

    // Advance 10 seconds
    act(() => {
      vi.advanceTimersByTime(10000);
    });
    expect(result.current.isRateLimited).toBe(true);
    expect(result.current.resetInSeconds).toBe(10);

    // Advance remaining 10 seconds
    act(() => {
      vi.advanceTimersByTime(10000);
    });
    expect(result.current.isRateLimited).toBe(false);
    expect(result.current.canExecute().allowed).toBe(true);
  });
});
