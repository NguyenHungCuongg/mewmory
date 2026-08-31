import { create } from "zustand";
import { vocabularyService } from "../services/vocabulary.service";

export const useVocabularyStore = create((set, get) => ({
  items: [],
  total: 0,
  isLoading: false,
  search: "",
  filters: {},
  sort: { field: "created_at", order: "desc" },
  offset: 0,

  setSearch: (search) => set({ search, offset: 0 }),
  setFilters: (filters) => set({ filters, offset: 0 }),
  setSort: (sort) => set({ sort, offset: 0 }),
  setOffset: (offset) => set({ offset }),

  fetchVocabularies: async (userId) => {
    set({ isLoading: true });
    try {
      const { search, filters, sort, offset } = get();
      const result = await vocabularyService.getAll(userId, {
        search,
        filters,
        sort,
        offset,
      });
      set({ items: result.items, total: result.total });
    } catch (error) {
      console.error("Failed to fetch vocabularies:", error);
    } finally {
      set({ isLoading: false });
    }
  },

  addVocabulary: async (vocabularyData, definitions) => {
    const result = await vocabularyService.create(vocabularyData, definitions);
    return result;
  },

  updateVocabulary: async (id, updates) => {
    return vocabularyService.update(id, updates);
  },

  deleteVocabulary: async (id) => {
    await vocabularyService.delete(id);
  },
}));
