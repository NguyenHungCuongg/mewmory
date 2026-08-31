import { create } from "zustand";
import { settingsService } from "../services/settings.service";

export const useSettingsStore = create((set, get) => ({
  settings: null,
  isLoading: false,

  fetchSettings: async (userId) => {
    if (!userId) return;
    set({ isLoading: true });
    try {
      const settings = await settingsService.get(userId);
      set({ settings });
    } catch (err) {
      console.error("Failed to fetch settings:", err);
    } finally {
      set({ isLoading: false });
    }
  },

  updateSettings: async (userId, updates) => {
    const updated = await settingsService.update(userId, updates);
    set({ settings: updated });
    return updated;
  },
}));
