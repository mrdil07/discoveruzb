# Tashqi xaritalardan kommentlar — sozlash

DiscoverUzb har post (joy) uchun **Google Maps**, **Yandex Maps** va
**2GIS**'dan reviewlarni avtomatik yig'ib, kechiktiribcache qiladi.

> Backend bu xizmatlarning **rasmiy API'larini** ishlatadi. Scraping yo'q.
> Cache TTL: default **24 soat** (`EXTERNAL_REVIEWS_CACHE_HOURS` env).

---

## 🗺 Arxitektura

```
┌──────────────────────────────────────────────────────────────────┐
│  Mobile / Admin                                                  │
│  GET /api/v1/posts/{id}/external-reviews                         │
└──────────────────────────────────┬───────────────────────────────┘
                                   │
                                   ▼
┌──────────────────────────────────────────────────────────────────┐
│  Backend `ReviewAggregator` (cache-first)                        │
│                                                                  │
│  1. DB'da `place_fetch_logs.last_fetched_at` ≤ 24h bo'lsa →     │
│     `external_reviews` jadvalidan o'qib qaytarish.               │
│  2. Aks holda → 3 ta provider'dan parallel HTTP fetch.          │
│  3. DB'ga upsert (idempotent `(post_id, source, external_id)`).  │
│  4. Aggregated response qaytarish.                               │
└──────────────────────┬──────────┬──────────┬─────────────────────┘
                       │          │          │
                       ▼          ▼          ▼
              ┌─────────────┐ ┌────────┐ ┌────────┐
              │ Google      │ │ Yandex │ │ 2GIS   │
              │ Places API  │ │ Maps   │ │ Catalog│
              └─────────────┘ └────────┘ └────────┘
```

**DB jadvallar:**

| Jadval | Vazifa |
|---|---|
| `posts.google_place_id`, `yandex_place_id`, `gis_place_id` | Tashqi platforma ID'lari |
| `external_reviews` | Cache'langan reviewlar (idempotent upsert) |
| `place_fetch_logs` | Har source uchun oxirgi fetch holati (TTL hisoboti) |

---

## 1. Google Places API (New)

### 1.1. API yoqish

1. <https://console.cloud.google.com/> → Sprint 7'da yaratgan loyihangiz.
2. **APIs & Services → Library**.
3. Qidiruvda **Places API (New)** ni toping va **Enable**.
4. **Credentials → Create credentials → API key**.
5. Yaratilgan API key'ni **Restrict** qilib, faqat *Places API (New)*'ga
   cheklang (xavfsizlik).

### 1.2. Backend sozlash

`backend/.env`:
```env
GOOGLE_PLACES_API_KEY=AIzaSy...
```

### 1.3. Post uchun `place_id` topish

Google Maps'da joyni ochib, URL'dan yoki **Place ID Finder** orqali:

- Brauzer URL formati: `https://www.google.com/maps/place/.../@<lat>,<lon>,17z/data=!4m6!3m5!1s<PLACE_ID>!...`
  `1s` dan keyingi qism — Place ID.
- **Place ID Finder**: <https://developers.google.com/maps/documentation/javascript/examples/places-placeid-finder>

Place ID format misoli: `ChIJsRyHpJALaBgRsbsOFv1eWQ4`

### 1.4. Post'ga ulash

Admin panel'da yoki API orqali:
```bash
curl -X PATCH https://api.discoveruzb.uz/api/v1/posts/<post_id> \
  -H "Authorization: Bearer <admin_jwt>" \
  -d '{"google_place_id": "ChIJsRyHpJALaBgRsbsOFv1eWQ4"}'
```

### 1.5. Narxi va limitlar

- **Free tier:** har oy $200 kredit (~10,000 Place Details so'rovi).
- **Place Details + Reviews:** $0.020 per request (yoki $20 / 1000).
- **Cache 24h ichida** so'rovlar takrorlamaydi → narxni minimal.

### 1.6. Cheklov

- Bitta Place Details javobi **eng ko'p 5 review** qaytaradi (Google qoidasi).
- Pagination yo'q.
- ToS: cache **30 kungacha** ruxsat (bizning TTL 24h — comfortable).

---

## 2. Yandex Maps Places API

### 2.1. API kalitini olish

1. <https://developer.tech.yandex.ru/services/> → ro'yxatdan o'tish.
2. **Yandex Maps API** → **Places API** (yoki Geosearch API) — ariza topshirish.
3. **APIkey** olish (manual moderation 1-2 ish kuni).

### 2.2. Backend sozlash

`backend/.env`:
```env
YANDEX_MAPS_API_KEY=<your-yandex-key>
```

### 2.3. Post uchun `place_id` (URI)

Yandex Maps'da joyni ochib:
- URL formati: `https://yandex.ru/maps/-/<KOD>` yoki `https://yandex.com/maps/org/<NAME>/<ORG_ID>/`
- `<ORG_ID>` — son shaklida — backend bu ID ni qabul qiladi.

Yoki Geosearch API orqali ism+manzil bo'yicha qidirib, `uri` field'ini olish.

### 2.4. Cheklov

- Yandex Maps Search API odatda **reviewlarni qaytarmaydi** —
  faqat `Feedback.rating` va `count`.
- To'liq reviewlar uchun **Yandex Maps for Business** API yoki
  Yandex.Maps Open Data kerak (qo'shimcha shartnoma).
- Bizning provider **average_rating** va **count**ni qaytaradi;
  reviewlar bo'sh array bo'lishi mumkin.

---

## 3. 2GIS Catalog API

### 3.1. API kalitini olish

1. <https://dev.2gis.ru/> → ro'yxatdan o'tish.
2. **API → Search Places (Catalog 3.0)** + **Reviews API** — yoqish.
3. Kalit olish (API console'da).

### 3.2. Backend sozlash

`backend/.env`:
```env
GIS_API_KEY=<your-2gis-key>
```

### 3.3. Post uchun `place_id` (Branch ID)

2GIS'da joyni ochib:
- URL formati: `https://2gis.uz/tashkent/firm/<BRANCH_ID>?...`
- `<BRANCH_ID>` — son shaklida (masalan `70030076175123456`).

Yoki Catalog API orqali `byname` qidiruv natijasidan `id` field.

### 3.4. Cheklov

- 2GIS rasmiy `reviews` API `key` orqali ishlaydi (rate-limit bilan).
- Free plan'da limitlar past — production'da paid plan tavsiya.
- 2GIS asosan **rus tilida** reviewlar — `locale=uz_UZ` parametri natijada cheklash.

---

## 4. API ishlatish

### 4.1. Reviewlarni o'qish

```http
GET /api/v1/posts/{post_id}/external-reviews
```

Javob:
```json
{
  "post_id": "01234567-89ab-cdef-0123-456789abcdef",
  "summaries": [
    {
      "source": "google",
      "review_count": 127,
      "average_rating": 4.6,
      "last_fetched_at": "2026-05-11T12:00:00Z",
      "error": null
    },
    {
      "source": "yandex",
      "review_count": 0,
      "average_rating": null,
      "error": "YANDEX_MAPS_API_KEY sozlanmagan"
    },
    {
      "source": "2gis",
      "review_count": 89,
      "average_rating": 4.4,
      "last_fetched_at": "2026-05-11T12:00:00Z",
      "error": null
    }
  ],
  "reviews": [
    {
      "id": "...",
      "post_id": "...",
      "source": "google",
      "external_id": "...",
      "author_name": "Aziz Karimov",
      "author_avatar_url": "https://...",
      "rating": 5.0,
      "text": "Juda chiroyli joy!",
      "language": "uz",
      "posted_at": "2026-04-15T10:00:00Z",
      "helpful_count": 0,
      "fetched_at": "2026-05-11T12:00:00Z"
    }
  ]
}
```

### 4.2. Cache'ni qayta yangilash (admin/moderator)

```http
POST /api/v1/posts/{post_id}/external-reviews/refresh
Authorization: Bearer <moderator_jwt>
Content-Type: application/json

{ "sources": ["google", "2gis"] }
```

`sources` bo'sh bo'lsa — barcha 3 source.

---

## 5. Frontend integratsiya

### 5.1. Mobile (Flutter)

`DetailsOfPlace` ekraniga **tabbar** qo'shing:
- **Sharhlar** (mahalliy `comments`)
- **Google Maps** (external `google` reviews)
- **Yandex Maps**
- **2GIS**

Har tab `GET /posts/{id}/external-reviews` chaqiradi va `source`'ga
ko'ra filtrlaydi.

> **TODO Sprint 10:** `lib/service/data_service.dart`'ga
> `loadExternalReviews(postId)` qo'shiladi.

### 5.2. Admin panel (Next.js)

Post edit sahifasida 3 ta input:
- **Google Place ID**
- **Yandex Place URI**
- **2GIS Branch ID**

Save'dan keyin "Refresh reviews" tugmasi —
`POST /posts/{id}/external-reviews/refresh`.

---

## 6. Tez-tez uchraydigan xatolar

| Xato | Sabab | Yechim |
|---|---|---|
| `place_id sozlanmagan` | Post'ga place_id qo'yilmagan | Admin panel orqali post'ni edit qiling |
| `GOOGLE_PLACES_API_KEY sozlanmagan` | `.env` to'ldirilmagan | §1.2 |
| `HTTP 403 — quota exceeded` | Bepul kredit tugagan | Billing yoqing yoki cache TTL'ni oshiring |
| `HTTP 404` (Google) | Place ID noto'g'ri | Place ID Finder bilan tekshiring |
| Reviewlar ko'rinmaydi (Yandex) | Yandex Search API reviewlarni qaytarmaydi | Bu provider asosan rating'ni beradi |

---

## 7. Xavfsizlik

- API kalitlar **faqat backend'da** ishlatiladi (mobile yoki admin
  panelga chiqarilmaydi).
- Google API key **Restrict to specific API** qilingan bo'lsin.
- Cache 24h — Google ToS bilan mos (max 30 kun ruxsat).
- Reviewlar foydalanuvchining shaxsiy ma'lumot emas — open data.

---

**So'nggi yangilanish:** 2026-05-11. Sprint 9.
