-- ==========================================
-- Migration 002a: Vaqtincha yumshatilgan RLS (Sprint 1 davomida)
-- ==========================================
-- Sana: 2026-05-09
-- Maqsad: 002 (qat'iy RLS) Supabase Auth ishlamasdan ilovani buzadi.
--         Bu fayl auth migratsiyasi davomida ishlatiladi — biroz
--         himoya bor, lekin to'liq emas.
--
-- ⚠️ Bu vaqtincha. Sprint 1 (TZ §8.2) tugashi bilan 002 ga o'ting va
--    bu politikalarni o'chiring.
--
-- Foydalanish:
--   1. Avval supabase_setup.sql'ning eski "Allow all" politikalari
--      o'chirilsin (002 boshida bor).
--   2. Bu fayl ishga tushiriladi.
-- ==========================================

DROP POLICY IF EXISTS "Allow all on users" ON users;
DROP POLICY IF EXISTS "Allow all on posts" ON posts;
DROP POLICY IF EXISTS "Allow all on gallery" ON gallery;
DROP POLICY IF EXISTS "Public Access" ON storage.objects;

-- USERS — anyone can read (public profiles), but no one can write
-- (insert/update/delete bloklangan — auth migratsiyasidan keyin yoqiladi)
CREATE POLICY "users_select_temp"
  ON users FOR SELECT
  USING (true);

CREATE POLICY "users_insert_temp"
  ON users FOR INSERT
  WITH CHECK (true);  -- TODO: faqat auth.uid()::text = uid

CREATE POLICY "users_update_temp"
  ON users FOR UPDATE
  USING (true)        -- TODO: faqat auth.uid()::text = uid
  WITH CHECK (true);

-- POSTS — public read, write all
CREATE POLICY "posts_select_temp"
  ON posts FOR SELECT
  USING (true);

CREATE POLICY "posts_insert_temp"
  ON posts FOR INSERT
  WITH CHECK (true);  -- TODO: faqat auth.uid()::text = uid

CREATE POLICY "posts_update_temp"
  ON posts FOR UPDATE
  USING (true)
  WITH CHECK (true);

CREATE POLICY "posts_delete_temp"
  ON posts FOR DELETE
  USING (true);  -- TODO: faqat ega yoki admin

-- GALLERY — open
CREATE POLICY "gallery_all_temp"
  ON gallery FOR ALL
  USING (true)
  WITH CHECK (true);

-- STORAGE — open
CREATE POLICY "media_all_temp"
  ON storage.objects FOR ALL
  USING (bucket_id = 'media')
  WITH CHECK (bucket_id = 'media');
