import { describe, it, expect, beforeEach } from "vitest";
import { renderHook, act } from "@testing-library/react";
import { useChartColors } from "../useChartColors";
import { useThemeStore } from "../../stores/theme.store";

describe("useChartColors", () => {
  beforeEach(() => {
    localStorage.clear();
  });

  it("returns light colors when theme is light", () => {
    act(() => {
      useThemeStore.getState().setTheme("light");
    });

    const { result } = renderHook(() => useChartColors());
    expect(result.current.isDark).toBe(false);
    expect(result.current.axisStroke).toBe("#a59f97");
    expect(result.current.barFillPrimary).toBe("#0b0b0b");
  });

  it("returns dark colors when theme is dark", () => {
    act(() => {
      useThemeStore.getState().setTheme("dark");
    });

    const { result } = renderHook(() => useChartColors());
    expect(result.current.isDark).toBe(true);
    expect(result.current.axisStroke).toBe("#8c8c87");
    expect(result.current.barFillPrimary).toBe("#f0f0ee");
  });
});
