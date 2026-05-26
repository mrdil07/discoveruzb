-- ==========================================
-- DiscoverUzb - Supabase Table Setup
-- SQL Editor'da ishga tushiring
-- ==========================================

-- 1. Users table
-- NOTE: `password` ustun 2026-05-09 da olib tashlandi (xavfsizlik).
-- Auth Supabase Phone OTP orqali boshqariladi (TZ §8.2).
CREATE TABLE IF NOT EXISTS users (
  uid TEXT PRIMARY KEY,
  fullname TEXT NOT NULL,
  "phoneNumber" TEXT NOT NULL,
  email TEXT DEFAULT '',
  "imgUrl" TEXT DEFAULT '',
  device_id TEXT DEFAULT '',
  device_type TEXT DEFAULT '',
  device_token TEXT DEFAULT '',
  role TEXT NOT NULL DEFAULT 'user'  -- 'user' | 'admin' (TZ §8.2)
);

-- 2. Posts table
CREATE TABLE IF NOT EXISTS posts (
  id TEXT PRIMARY KEY,
  uid TEXT,
  "placeImage" JSONB DEFAULT '[]',
  "userImage" TEXT,
  "placeInfo" TEXT NOT NULL DEFAULT '',
  "placeName" TEXT NOT NULL DEFAULT '',
  address TEXT NOT NULL DEFAULT '',
  type TEXT NOT NULL DEFAULT '',
  source TEXT NOT NULL DEFAULT '',
  time BIGINT NOT NULL DEFAULT 0,
  "phoneNumber" JSONB DEFAULT '[]',
  price TEXT NOT NULL DEFAULT '',
  comments JSONB DEFAULT '[]',
  liked JSONB DEFAULT '[]',
  saved JSONB DEFAULT '[]',
  "likeCount" INTEGER DEFAULT 0,
  lat DOUBLE PRECISION NOT NULL DEFAULT 0,
  lon DOUBLE PRECISION NOT NULL DEFAULT 0
);

-- 3. Gallery table
CREATE TABLE IF NOT EXISTS gallery (
  id SERIAL PRIMARY KEY,
  "placeName" TEXT NOT NULL,
  images JSONB DEFAULT '[]',
  date TEXT NOT NULL
);

-- 4. Storage bucket yaratish
INSERT INTO storage.buckets (id, name, public)
VALUES ('media', 'media', true)
ON CONFLICT (id) DO NOTHING;

-- 5. RLS (Row Level Security) yoqish
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE gallery ENABLE ROW LEVEL SECURITY;

-- 6. RLS politikalar uchun migrations/ papkasiga qarang:
--    - migrations/002_rewrite_rls_policies.sql (Supabase Auth bilan, qat'iy)
--    - migrations/002a_temp_relaxed_rls.sql (vaqtincha, Auth migratsiyasidan oldin)
--
-- Yangi loyiha uchun: avval 002a ni qo'llang, keyin Supabase Auth
-- ishga tushgandan keyin 002 ga o'ting.
--
-- ⚠️ Eski "Allow all" politikalar olib tashlandi — xavfsizlik kritik
--    (har kim har qanday ma'lumotni o'zgartira olardi).
