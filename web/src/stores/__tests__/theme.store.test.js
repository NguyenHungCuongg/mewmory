import { describe, it, expect, beforeEach, vi } from "vitest";
import { useThemeStore } from "../theme.store";

describe("useThemeStore", () => {
  beforeEach(() => {
    localStorage.clear();
    document.documentElement.removeAttribute("data-theme");
  });

  it("sets dark theme correctly", () => {
    const { setTheme } = useThemeStore.getState();
    setTheme("dark");

    const state = useThemeStore.getState();
    expect(state.theme).toBe("dark");
    expect(state.resolvedTheme).toBe("dark");
    expect(localStorage.getItem("mewmory-theme")).toBe("dark");
    expect(document.documentElement.dataset.theme).toBe("dark");
  });

  it("sets light theme correctly", () => {
    const { setTheme } = useThemeStore.getState();
    setTheme("light");

    const state = useThemeStore.getState();
    expect(state.theme).toBe("light");
    expect(state.resolvedTheme).toBe("light");
    expect(localStorage.getItem("mewmory-theme")).toBe("light");
    expect(document.documentElement.dataset.theme).toBe("light");
  });

  it("cycles themes with toggleTheme", () => {
    const { setTheme, toggleTheme } = useThemeStore.getState();
    setTheme("light");

    toggleTheme();
    expect(useThemeStore.getState().theme).toBe("dark");

    toggleTheme();
    expect(useThemeStore.getState().theme).toBe("system");

    toggleTheme();
    expect(useThemeStore.getState().theme).toBe("light");
  });

  it("ignores invalid themes", () => {
    const { setTheme } = useThemeStore.getState();
    setTheme("light");
    setTheme("neon-pink");

    expect(useThemeStore.getState().theme).toBe("light");
  });
});
