import { create } from "zustand";

let toastId = 0;

export const useUIStore = create((set) => ({
  toasts: [],
  sidebarOpen: true,

  addToast: (message, type = "success") => {
    const id = ++toastId;
    set((state) => ({
      toasts: [...state.toasts, { id, message, type }],
    }));
    return id;
  },

  removeToast: (id) =>
    set((state) => ({
      toasts: state.toasts.filter((t) => t.id !== id),
    })),

  toggleSidebar: () => set((state) => ({ sidebarOpen: !state.sidebarOpen })),
}));
