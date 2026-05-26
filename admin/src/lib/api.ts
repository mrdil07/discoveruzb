/**
 * Backend API klient (axios + JWT interceptor + auto-refresh).
 *
 * Token cookie'larda saqlanadi (Next.js SSR uchun ham qulay).
 */

import axios, { AxiosError, type AxiosInstance, type AxiosRequestConfig } from "axios";

export const API_URL =
  process.env.NEXT_PUBLIC_API_URL ?? "http://localhost:8000/api/v1";

const ACCESS_TOKEN_KEY = "discoveruzb_access";
const REFRESH_TOKEN_KEY = "discoveruzb_refresh";

// ===== Token helpers =====

export const tokenStorage = {
  getAccess(): string | null {
    if (typeof window === "undefined") return null;
    return localStorage.getItem(ACCESS_TOKEN_KEY);
  },
  getRefresh(): string | null {
    if (typeof window === "undefined") return null;
    return localStorage.getItem(REFRESH_TOKEN_KEY);
  },
  set(access: string, refresh: string): void {
    if (typeof window === "undefined") return;
    localStorage.setItem(ACCESS_TOKEN_KEY, access);
    localStorage.setItem(REFRESH_TOKEN_KEY, refresh);
    // Cookie ham yozamiz (route guards uchun, middleware'da o'qish mumkin)
    document.cookie = `${ACCESS_TOKEN_KEY}=${access}; path=/; max-age=3600; SameSite=Lax`;
  },
  clear(): void {
    if (typeof window === "undefined") return;
    localStorage.removeItem(ACCESS_TOKEN_KEY);
    localStorage.removeItem(REFRESH_TOKEN_KEY);
    document.cookie = `${ACCESS_TOKEN_KEY}=; path=/; max-age=0`;
  },
};

// ===== Axios instance =====

export const api: AxiosInstance = axios.create({
  baseURL: API_URL,
  timeout: 20_000,
  headers: { "Content-Type": "application/json" },
});

api.interceptors.request.use((config) => {
  if (config.noAuth) return config;
  const token = tokenStorage.getAccess();
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

let refreshPromise: Promise<string> | null = null;

api.interceptors.response.use(
  (response) => response,
  async (error: AxiosError) => {
    const original = error.config as
      | (AxiosRequestConfig & { _retry?: boolean })
      | undefined;
    if (
      error.response?.status === 401 &&
      original &&
      !original._retry &&
      !original.url?.includes("/auth/refresh")
    ) {
      original._retry = true;

      try {
        const newAccess = await (refreshPromise ??= refreshTokens());
        if (original.headers) {
          original.headers.Authorization = `Bearer ${newAccess}`;
        }
        return api(original);
      } catch {
        tokenStorage.clear();
        if (typeof window !== "undefined") {
          window.location.href = "/login";
        }
      } finally {
        refreshPromise = null;
      }
    }
    return Promise.reject(error);
  },
);

async function refreshTokens(): Promise<string> {
  const refresh = tokenStorage.getRefresh();
  if (!refresh) throw new Error("No refresh token");

  const response = await axios.post(
    `${API_URL}/auth/refresh`,
    { refresh_token: refresh },
    { headers: { "Content-Type": "application/json" } },
  );
  const { access_token, refresh_token } = response.data as {
    access_token: string;
    refresh_token: string;
  };
  tokenStorage.set(access_token, refresh_token ?? refresh);
  return access_token;
}

// ===== Helpers =====

export function extractErrorMessage(error: unknown, fallback = "Xatolik"): string {
  if (axios.isAxiosError(error)) {
    const detail = error.response?.data?.detail;
    if (typeof detail === "string") return detail;
  }
  return fallback;
}
