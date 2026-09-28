import { describe, it, expect, beforeEach, afterEach, vi } from "vitest";
import { renderHook, act } from "@testing-library/react";
import { useSync, PENDING_SYNC_INTERVAL_MS } from "../useSync";
import { syncEngine } from "../../db/sync";

const user = { id: "u1" };

vi.mock("../useOnlineStatus", () => ({
  useOnlineStatus: () => ({ isOnline: true }),
}));
vi.mock("../../stores/auth.store", () => ({
  useAuthStore: () => ({ user }),
}));
vi.mock("../../db/sync", () => ({
  syncEngine: {
    fullSync: vi.fn(),
    pendingCount: vi.fn(),
  },
}));

beforeEach(() => {
  vi.useFakeTimers();
  vi.clearAllMocks();
  syncEngine.fullSync.mockResolvedValue({ pushed: 0, pulled: 0, errors: [] });
});

afterEach(() => {
  vi.useRealTimers();
});

describe("useSync", () => {
  it("syncs again while online when local changes are waiting", async () => {
    syncEngine.pendingCount.mockResolvedValue(2);
    renderHook(() => useSync());
    await act(() => vi.advanceTimersByTimeAsync(0));
    expect(syncEngine.fullSync).toHaveBeenCalledTimes(1); // on mount

    await act(() => vi.advanceTimersByTimeAsync(PENDING_SYNC_INTERVAL_MS));
    expect(syncEngine.fullSync).toHaveBeenCalledTimes(2);
  });

  it("does not sync on the interval when nothing is waiting", async () => {
    syncEngine.pendingCount.mockResolvedValue(0);
    renderHook(() => useSync());
    await act(() => vi.advanceTimersByTimeAsync(0));

    await act(() => vi.advanceTimersByTimeAsync(PENDING_SYNC_INTERVAL_MS * 3));
    expect(syncEngine.fullSync).toHaveBeenCalledTimes(1);
  });
});
