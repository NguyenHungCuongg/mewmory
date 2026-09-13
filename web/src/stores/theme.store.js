import { create } from "zustand";

const THEME_STORAGE_KEY = "mewmory-theme";
const VALID_THEMES = ["light", "dark", "system"];

function getSystemTheme() {
  if (typeof window === "undefined" || !window.matchMedia) {
    return "light";
  }
  return window.matchMedia("(prefers-color-scheme: dark)").matches
    ? "dark"
    : "light";
}

function applyTheme(resolvedTheme) {
  if (typeof document !== "undefined" && document.documentElement) {
    document.documentElement.dataset.theme = resolvedTheme;
  }
}

function getStoredTheme() {
  if (typeof window === "undefined" || !window.localStorage) {
    return "system";
  }
  try {
    const stored = localStorage.getItem(THEME_STORAGE_KEY);
    if (stored && VALID_THEMES.includes(stored)) {
      return stored;
    }
  } catch {
    // Ignore storage access errors
  }
  return "system";
}

const initialTheme = getStoredTheme();
const initialResolved =
  initialTheme === "system" ? getSystemTheme() : initialTheme;
applyTheme(initialResolved);

export const useThemeStore = create((set, get) => {
  // Listen for OS color scheme changes
  if (typeof window !== "undefined" && window.matchMedia) {
    try {
      const mediaQuery = window.matchMedia("(prefers-color-scheme: dark)");
      const handleChange = (e) => {
        const state = get();
        if (state.theme === "system") {
          const newResolved = e.matches ? "dark" : "light";
          applyTheme(newResolved);
          set({ resolvedTheme: newResolved });
        }
      };

      if (mediaQuery.addEventListener) {
        mediaQuery.addEventListener("change", handleChange);
      } else if (mediaQuery.addListener) {
        mediaQuery.addListener(handleChange);
      }
    } catch {
      // Ignore media query listener errors
    }
  }

  return {
    theme: initialTheme,
    resolvedTheme: initialResolved,

    setTheme: (newTheme) => {
      if (!VALID_THEMES.includes(newTheme)) return;

      try {
        localStorage.setItem(THEME_STORAGE_KEY, newTheme);
      } catch {
        // Ignore storage access errors
      }

      const resolved =
        newTheme === "system" ? getSystemTheme() : newTheme;
      applyTheme(resolved);
      set({ theme: newTheme, resolvedTheme: resolved });
    },

    toggleTheme: () => {
      const current = get().theme;
      const cycle = {
        light: "dark",
        dark: "system",
        system: "light",
      };
      const next = cycle[current] || "system";
      get().setTheme(next);
    },
  };
});
