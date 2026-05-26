-- ==========================================
-- Fix: posts va gallery table'larni tuzatish
-- 1 marta ishga tushiring - doimiy saqlanadi
-- ==========================================

-- Eski table'larni o'chirish (data bo'sh)
DROP POLICY IF EXISTS "Allow all on posts" ON posts;
DROP POLICY IF EXISTS "Allow all on gallery" ON gallery;
DROP TABLE IF EXISTS posts;
DROP TABLE IF EXISTS gallery;

-- Posts table
CREATE TABLE posts (
  id TEXT PRIMARY KEY,
  uid TEXT,
  "placeImage" JSONB DEFAULT '[]'::jsonb,
  "userImage" TEXT,
  "placeInfo" TEXT NOT NULL DEFAULT '',
  "placeName" TEXT NOT NULL DEFAULT '',
  address TEXT NOT NULL DEFAULT '',
  type TEXT NOT NULL DEFAULT '',
  source TEXT NOT NULL DEFAULT '',
  time BIGINT NOT NULL DEFAULT 0,
  "phoneNumber" JSONB DEFAULT '[]'::jsonb,
  price TEXT NOT NULL DEFAULT '',
  comments JSONB DEFAULT '[]'::jsonb,
  liked JSONB DEFAULT '[]'::jsonb,
  saved JSONB DEFAULT '[]'::jsonb,
  "likeCount" INTEGER DEFAULT 0,
  lat DOUBLE PRECISION NOT NULL DEFAULT 0,
  lon DOUBLE PRECISION NOT NULL DEFAULT 0
);

-- Gallery table
CREATE TABLE gallery (
  id SERIAL PRIMARY KEY,
  "placeName" TEXT NOT NULL,
  images JSONB DEFAULT '[]'::jsonb,
  date TEXT NOT NULL
);

-- RLS yoqish
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE gallery ENABLE ROW LEVEL SECURITY;

-- Policy yaratish
CREATE POLICY "Allow all on posts" ON posts FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all on gallery" ON gallery FOR ALL USING (true) WITH CHECK (true);
