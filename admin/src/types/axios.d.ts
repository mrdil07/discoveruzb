/**
 * Axios `AxiosRequestConfig`'ga `noAuth` flag'ini qo'shamiz.
 * Auth oqimi (login, register, refresh) uchun JWT interceptor'ni
 * o'tkazib yuborish kerak.
 */
import "axios";

declare module "axios" {
  export interface AxiosRequestConfig {
    /** `true` bo'lsa — interceptor `Authorization` headerni qo'shmaydi. */
    noAuth?: boolean;
  }
}

export {};
