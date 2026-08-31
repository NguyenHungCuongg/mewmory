import { create } from "zustand";
import { collectionService } from "../services/collection.service";

export const useCollectionStore = create((set, get) => ({
  items: [],
  isLoading: false,

  fetchCollections: async (userId) => {
    set({ isLoading: true });
    try {
      const result = await collectionService.getAll(userId);
      set({ items: result.items });
    } catch (error) {
      console.error("Failed to fetch collections:", error);
    } finally {
      set({ isLoading: false });
    }
  },

  addCollection: async (data) => {
    const newCollection = await collectionService.create(data);
    newCollection.word_count = 0;
    set((state) => ({ items: [...state.items, newCollection] }));
    return newCollection;
  },

  updateCollection: async (id, updates) => {
    const updated = await collectionService.update(id, updates);
    set((state) => ({
      items: state.items.map((item) =>
        item.id === id ? { ...item, ...updated } : item,
      ),
    }));
    return updated;
  },

  deleteCollection: async (id) => {
    await collectionService.delete(id);
    set((state) => ({
      items: state.items.filter((item) => item.id !== id),
    }));
  },
}));
