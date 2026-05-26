-- ==========================================
-- Migration 002: RLS politikalarni qayta yozish
-- ==========================================
-- Sana: 2026-05-09
-- Sabab: Hozirgi politikalar `Allow all` — har kim har qanday post,
--        user, galereyani o'qishi va o'zgartirishi mumkin. Bu kritik
--        xavfsizlik zaifligi (TZ §9.4, security-rules.md).
--
-- Bu migratsiya quyidagilarni qiladi:
--   1. Eski "Allow all" politikalarni o'chiradi.
--   2. `users` — faqat ega o'zini ko'radi/yangilaydi (auth.uid() bilan).
--   3. `posts` — SELECT public, INSERT/UPDATE/DELETE faqat ega.
--   4. `gallery` — faqat ega.
--   5. Storage `media` — public READ, ega yozadi/o'chiradi.
--
-- ⚠️ DIQQAT: Bu politikalar Supabase Auth ishlatilishini taxmin qiladi
--    (auth.uid() qiymati JWT'dan keladi). Hozirda ilova Supabase Auth
--    ishlatmaydi — anonymous client orqali so'rov yuboriladi va
--    auth.uid() = NULL bo'ladi. Shuning uchun BU MIGRATSIYA SUPABASE
--    AUTH'GA O'TGANDAN KEYIN QO'LLANILSIN (TZ §8.2 Sprint 1).
--
-- Vaqtincha (Auth migratsiyasidan oldin) variant — `migrations/
-- 002a_temp_relaxed_rls.sql`'da. Production'da bu variantni
-- ishlatmang.
-- ==========================================

-- ===== Eski "Allow all" politikalarni o'chirish =====

DROP POLICY IF EXISTS "Allow all on users" ON users;
DROP POLICY IF EXISTS "Allow all on posts" ON posts;
DROP POLICY IF EXISTS "Allow all on gallery" ON gallery;
DROP POLICY IF EXISTS "Public Access" ON storage.objects;

-- ===== USERS jadvali =====

-- Har user faqat o'zini ko'radi
CREATE POLICY "users_select_own"
  ON users FOR SELECT
  USING (auth.uid()::text = uid);

-- Yangi user yaratish — faqat ro'yxatdan o'tish vaqtida (auth.uid() = uid)
CREATE POLICY "users_insert_self"
  ON users FOR INSERT
  WITH CHECK (auth.uid()::text = uid);

-- O'zini yangilash
CREATE POLICY "users_update_own"
  ON users FOR UPDATE
  USING (auth.uid()::text = uid)
  WITH CHECK (auth.uid()::text = uid);

-- O'chirish admin huquqida (kelajakda role claim bilan)
-- CREATE POLICY "users_delete_admin"
--   ON users FOR DELETE
--   USING (auth.jwt() ->> 'role' = 'admin');

-- ===== POSTS jadvali =====

-- Postlarni hamma ko'radi (public catalog)
CREATE POLICY "posts_select_public"
  ON posts FOR SELECT
  USING (true);

-- Yangi post — faqat o'zini avtor sifatida belgilash mumkin
CREATE POLICY "posts_insert_authenticated"
  ON posts FOR INSERT
  WITH CHECK (auth.uid()::text = uid);

-- Faqat ega yangilashi mumkin (layk/saqlash uchun alohida RPC kerak —
-- chunki layk bosgan user post egasi emas)
CREATE POLICY "posts_update_owner"
  ON posts FOR UPDATE
  USING (auth.uid()::text = uid)
  WITH CHECK (auth.uid()::text = uid);

-- Faqat ega yoki admin o'chiradi
CREATE POLICY "posts_delete_owner_or_admin"
  ON posts FOR DELETE
  USING (
    auth.uid()::text = uid
    OR auth.jwt() ->> 'role' = 'admin'
  );

-- TODO: Layk va saqlash uchun RPC funksiyalar yaratish
-- (chunki user boshqa user'ning postiga `liked` array'ga o'zini
-- qo'shishi kerak — RLS bilan to'g'ridan-to'g'ri UPDATE imkonsiz):
--
-- CREATE OR REPLACE FUNCTION toggle_like(post_id text)
-- RETURNS void
-- LANGUAGE plpgsql
-- SECURITY DEFINER
-- AS $$
-- BEGIN
--   ...
-- END;
-- $$;

-- ===== GALLERY jadvali =====

-- Hozirgi schema'da gallery'da `uid` ustun yo'q — qo'shish kerak
ALTER TABLE gallery ADD COLUMN IF NOT EXISTS uid TEXT;

CREATE POLICY "gallery_select_own"
  ON gallery FOR SELECT
  USING (auth.uid()::text = uid);

CREATE POLICY "gallery_insert_authenticated"
  ON gallery FOR INSERT
  WITH CHECK (auth.uid()::text = uid);

CREATE POLICY "gallery_update_own"
  ON gallery FOR UPDATE
  USING (auth.uid()::text = uid)
  WITH CHECK (auth.uid()::text = uid);

CREATE POLICY "gallery_delete_own"
  ON gallery FOR DELETE
  USING (auth.uid()::text = uid);

-- ===== STORAGE: media bucket =====

-- Public READ (post rasmlari, profil rasmlari)
CREATE POLICY "media_select_public"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'media');

-- Faqat autentifikatsiyalangan user yuklaydi
CREATE POLICY "media_insert_authenticated"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'media'
    AND auth.uid() IS NOT NULL
  );

-- Faqat ega o'chiradi (rasmga `owner` field Supabase tomonidan
-- avtomatik qo'shiladi)
CREATE POLICY "media_delete_owner"
  ON storage.objects FOR DELETE
  USING (
    bucket_id = 'media'
    AND owner = auth.uid()
  );

-- ===== Tasdiqlash =====
-- SELECT schemaname, tablename, policyname, cmd
-- FROM pg_policies
-- WHERE schemaname IN ('public', 'storage')
-- ORDER BY tablename, policyname;
