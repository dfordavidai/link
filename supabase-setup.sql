-- ============================================================
-- LinkHub — Supabase Database Setup
-- Run in: Supabase Dashboard → SQL Editor → New Query → Run
-- ============================================================

-- 1. BACKLINKS
CREATE TABLE IF NOT EXISTS public.backlinks (
  id          BIGSERIAL PRIMARY KEY,
  url         TEXT NOT NULL,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE public.backlinks ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read backlinks" ON public.backlinks FOR SELECT USING (true);
CREATE POLICY "Admin insert backlinks" ON public.backlinks FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Admin delete backlinks" ON public.backlinks FOR DELETE USING (auth.role() = 'authenticated');

-- 2. NEWS CACHE (headline list, refreshed hourly)
CREATE TABLE IF NOT EXISTS public.news_cache (
  id          BIGSERIAL PRIMARY KEY,
  slug        TEXT UNIQUE NOT NULL,
  title       TEXT,
  source      TEXT,
  category    TEXT,
  url         TEXT,
  updated_at  TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE public.news_cache ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read news_cache" ON public.news_cache FOR SELECT USING (true);
CREATE POLICY "Allow insert news_cache" ON public.news_cache FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow update news_cache" ON public.news_cache FOR UPDATE USING (true);
CREATE POLICY "Admin delete news_cache" ON public.news_cache FOR DELETE USING (true);

-- 3. NEWS ARTICLES (full article content, cached after first click)
CREATE TABLE IF NOT EXISTS public.news_articles (
  id          BIGSERIAL PRIMARY KEY,
  slug        TEXT UNIQUE NOT NULL,
  title       TEXT,
  category    TEXT,
  source      TEXT,
  summary     TEXT,
  body        TEXT,
  source_url  TEXT,
  updated_at  TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE public.news_articles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read news_articles" ON public.news_articles FOR SELECT USING (true);
CREATE POLICY "Allow insert news_articles" ON public.news_articles FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow update news_articles" ON public.news_articles FOR UPDATE USING (true);

-- ============================================================
-- AFTER RUNNING THIS SQL:
-- Go to: Authentication → Users → Add User
-- Set your admin email & password
-- Use those credentials to log into the site admin panel
-- ============================================================
