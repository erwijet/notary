import { create } from "zustand";
import { persist, createJSONStorage } from "zustand/middleware";

type PortalStore = {
  token?: string;
  setToken: (token: string) => void;
  clearToken: () => void;
};

export const usePortalStore = create<PortalStore>()(
  persist(
    (set, get) => ({
      setToken(token) {
        set({ token });
      },
      clearToken() {
        set({ token: undefined });
      }
    }),
    {
      name: "dev.holewinski.portal",
      storage: createJSONStorage(() => localStorage),
    }
  )
);
