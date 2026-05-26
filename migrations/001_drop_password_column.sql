-- ==========================================
-- Migration 001: users.password ustunini o'chirish
-- ==========================================
-- Sana: 2026-05-09
-- Sabab: Plain-text parol DB da saqlanmasligi kerak. Auth Supabase
--        Phone OTP orqali boshqariladi (kelajakda Supabase Auth'ga
--        to'liq o'tish — TZ §8.2).
--
-- Bu migratsiya `users` jadvalidan `password` ustunini olib tashlaydi.
-- Ilovaning Dart kodi `Users` modelida bu fieldni endi yubormaydi
-- (lib/models/users_model.dart).
--
-- Foydalanish:
--   Supabase dashboard → SQL Editor → paste → Run
--
-- Yoki Supabase CLI:
--   supabase db execute -f migrations/001_drop_password_column.sql
-- ==========================================

ALTER TABLE users DROP COLUMN IF EXISTS password;

-- Tasdiqlash:
-- SELECT column_name FROM information_schema.columns
-- WHERE table_name = 'users' AND table_schema = 'public';
