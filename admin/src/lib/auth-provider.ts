/**
 * Refine auth provider — backend admin login (email/telefon + parol +
 * reCAPTCHA) bilan ishlaydi.
 *
 * Backend `/auth/admin/login` endpoint role tekshiruvini ham, parol
 * tekshiruvini ham o'zi bajaradi. Bu yerda biz qaytgan tokenlarni saqlab
 * qo'yamiz.
 */

import type { AuthProvider } from "@refinedev/core";
import { api, extractErrorMessage, tokenStorage } from "@/lib/api";

export interface User {
  id: string;
  fullname: string;
  phone: string | null;
  email: string | null;
  role: "user" | "moderator" | "admin";
  img_url: string | null;
  language: string;
}

interface LoginParams {
  identifier: string;
  password: string;
  recaptcha_token: string;
}

export const authProvider: AuthProvider = {
  /**
   * Admin login endpoint'ini chaqiradi.
   * Login formidan `{ identifier, password, recaptcha_token }` keladi.
   */
  async login({ identifier, password, recaptcha_token }: LoginParams) {
    try {
      const response = await api.post(
        "/auth/admin/login",
        { identifier, password, recaptcha_token },
        { noAuth: true },
      );
      const { access_token, refresh_token, user } = response.data as {
        access_token: string;
        refresh_token: string;
        user: User;
      };

      // Backend allaqachon role tekshirdi, lekin defense-in-depth uchun
      // bu yerda ham tekshiramiz.
      if (user.role !== "admin" && user.role !== "moderator") {
        return {
          success: false,
          error: {
            name: "ForbiddenError",
            message: "Bu hisob admin paneli uchun ruxsatga ega emas",
          },
        };
      }

      tokenStorage.set(access_token, refresh_token);
      return { success: true, redirectTo: "/" };
    } catch (error) {
      return {
        success: false,
        error: {
          name: "LoginError",
          message: extractErrorMessage(error, "Kirish amalga oshmadi"),
        },
      };
    }
  },

  async logout() {
    const refresh = tokenStorage.getRefresh();
    if (refresh) {
      try {
        await api.post(
          "/auth/logout",
          { refresh_token: refresh },
          { noAuth: true },
        );
      } catch {
        // Mahalliy tokenlarni baribir tozalaymiz
      }
    }
    tokenStorage.clear();
    return { success: true, redirectTo: "/login" };
  },

  async check() {
    const token = tokenStorage.getAccess();
    if (!token) {
      return { authenticated: false, redirectTo: "/login" };
    }
    return { authenticated: true };
  },

  async getIdentity(): Promise<User | null> {
    const token = tokenStorage.getAccess();
    if (!token) return null;
    try {
      const response = await api.get("/auth/me");
      return response.data as User;
    } catch {
      return null;
    }
  },

  async getPermissions() {
    const identity = (await this.getIdentity?.()) as User | null;
    return identity?.role ?? null;
  },

  async onError(error) {
    if (error?.statusCode === 401 || error?.response?.status === 401) {
      return { logout: true, redirectTo: "/login" };
    }
    return {};
  },
};
