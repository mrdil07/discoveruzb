/**
 * Refine data provider — backend FastAPI bilan ishlaydi.
 *
 * Backend `Page<T>` formatida javob beradi:
 *   { items, total, page, size, total_pages }
 *
 * Refine `simple-rest` provider'ini orqada ishlatadi va response'larni
 * Refine kutadigan formatga moslashtiradi.
 */

import type { DataProvider } from "@refinedev/core";
import { api, API_URL, extractErrorMessage } from "@/lib/api";

interface BackendPage<T> {
  items: T[];
  total: number;
  page: number;
  size: number;
  total_pages: number;
}

export const dataProvider: DataProvider = {
  getApiUrl: () => API_URL,

  async getList({ resource, pagination, filters, sorters }) {
    const params: Record<string, string | number> = {
      page: pagination?.current ?? 1,
      size: pagination?.pageSize ?? 20,
    };

    // Filterlar (oddiy `eq` filterlar uchun)
    if (filters) {
      for (const filter of filters) {
        if ("field" in filter && filter.value !== undefined && filter.value !== "") {
          params[filter.field] = filter.value as string;
        }
      }
    }

    // Sorting (backend `?sort=&order=` formatini ishlatadi)
    if (sorters && sorters.length > 0) {
      const sorter = sorters[0];
      params.sort = sorter.field;
      params.order = sorter.order;
    }

    try {
      const response = await api.get<BackendPage<unknown> | unknown[]>(
        `/${resource}`,
        { params },
      );

      const data = response.data;
      // Backend ba'zan oddiy array qaytaradi (masalan `/posts/famous`)
      if (Array.isArray(data)) {
        return { data: data as never, total: data.length };
      }
      const page = data as BackendPage<unknown>;
      return { data: page.items as never, total: page.total };
    } catch (error) {
      throw new Error(extractErrorMessage(error, "Ro'yxatni yuklashda xatolik"));
    }
  },

  async getOne({ resource, id }) {
    const response = await api.get(`/${resource}/${id}`);
    return { data: response.data };
  },

  async create({ resource, variables }) {
    const response = await api.post(`/${resource}`, variables);
    return { data: response.data };
  },

  async update({ resource, id, variables }) {
    // Backend PATCH (partial update) ishlatadi
    const path =
      resource === "users" ? `/users/admin/${id}` : `/${resource}/${id}`;
    const response = await api.patch(path, variables);
    return { data: response.data };
  },

  async deleteOne({ resource, id }) {
    const path =
      resource === "users" ? `/users/admin/${id}` : `/${resource}/${id}`;
    const response = await api.delete(path);
    return { data: response.data };
  },

  async custom({ url, method, payload, query, headers }) {
    const config = {
      params: query,
      headers,
    };
    let response;
    switch (method) {
      case "post":
        response = await api.post(url, payload, config);
        break;
      case "put":
        response = await api.put(url, payload, config);
        break;
      case "patch":
        response = await api.patch(url, payload, config);
        break;
      case "delete":
        response = await api.delete(url, { ...config, data: payload });
        break;
      default:
        response = await api.get(url, config);
    }
    return { data: response.data };
  },
};
