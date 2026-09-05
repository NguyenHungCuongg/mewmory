import { useThemeStore } from "../stores/theme.store";

export function useChartColors() {
  const { resolvedTheme } = useThemeStore();
  const isDark = resolvedTheme === "dark";

  return {
    isDark,
    axisStroke: isDark ? "#8c8c87" : "#a59f97",
    axisLine: isDark ? "#2e2e2b" : "#ebe8e4",
    tooltipBg: isDark ? "#1c1c1a" : "#ffffff",
    tooltipBorder: isDark ? "#2e2e2b" : "#e6e6e3",
    tooltipText: isDark ? "#f0f0ee" : "#0b0b0b",
    tooltipShadow: isDark
      ? "rgba(0, 0, 0, 0.35) 0px 4px 12px"
      : "rgba(0, 0, 0, 0.04) 0px 2px 4px",
    barFillPrimary: isDark ? "#f0f0ee" : "#0b0b0b",
    barFillSecondary: isDark ? "#8c8c87" : "#60605c",
    legendText: isDark ? "#c8c8c4" : "#30302e",
  };
}
