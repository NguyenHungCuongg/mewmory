import { create } from "zustand";

export const useAuthStore = create((set) => ({
  user: null,
  session: null,
  isAdmin: false,
  isLoading: true,

  setUser: (user) => set({ user }),
  setSession: (session) => set({ session }),
  setLoading: (isLoading) => set({ isLoading }),
  setIsAdmin: (isAdmin) => set({ isAdmin }),

  signOut: () =>
    set({ user: null, session: null, isAdmin: false, isLoading: false }),
}));
