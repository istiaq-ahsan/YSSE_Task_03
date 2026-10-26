-- YSSE Portal — PostgreSQL schema
-- This script mirrors the schema inspected in Supabase on 2026-10-26.
-- Run on a NEW/empty public schema. It is not a migration for an existing database.

CREATE TABLE IF NOT EXISTS public.opportunities (
    id BIGSERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    type TEXT NOT NULL,
    amount TEXT NOT NULL DEFAULT '',
    deadline DATE NOT NULL,
    description TEXT NOT NULL,
    eligibility TEXT NOT NULL DEFAULT '',
    application_url TEXT NOT NULL DEFAULT '',
    status TEXT NOT NULL DEFAULT 'open',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT opportunities_status_check CHECK (status IN ('open', 'closed'))
);

CREATE TABLE IF NOT EXISTS public.applications (
    id BIGSERIAL PRIMARY KEY,
    opportunity_id BIGINT NOT NULL,
    applicant_uid TEXT NOT NULL,
    full_name TEXT NOT NULL,
    email TEXT NOT NULL,
    phone TEXT NOT NULL,
    institution TEXT NOT NULL,
    department TEXT NOT NULL,
    semester TEXT NOT NULL,
    cv_url TEXT NOT NULL DEFAULT '',
    linkedin_url TEXT NOT NULL DEFAULT '',
    motivation TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT applications_opportunity_id_fkey
        FOREIGN KEY (opportunity_id) REFERENCES public.opportunities(id) ON DELETE CASCADE,
    CONSTRAINT applications_status_check
        CHECK (status IN ('pending', 'reviewing', 'accepted', 'rejected')),
    CONSTRAINT unique_opportunity_applicant UNIQUE (opportunity_id, applicant_uid)
);

CREATE TABLE IF NOT EXISTS public.programs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    duration TEXT NOT NULL,
    mode TEXT NOT NULL DEFAULT 'Online',
    enrolled INTEGER NOT NULL DEFAULT 0,
    seats INTEGER NOT NULL DEFAULT 30,
    status TEXT NOT NULL DEFAULT 'open',
    image_color TEXT NOT NULL DEFAULT 'from-emerald-500 to-teal-600',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT programs_mode_check CHECK (mode IN ('Online', 'Offline', 'Hybrid')),
    CONSTRAINT programs_seats_check CHECK (seats >= 1),
    CONSTRAINT programs_enrolled_check CHECK (enrolled >= 0 AND enrolled <= seats),
    CONSTRAINT programs_status_check CHECK (status IN ('open', 'closed'))
);

CREATE TABLE IF NOT EXISTS public.events (
    id SERIAL PRIMARY KEY,
    title VARCHAR NOT NULL,
    description TEXT DEFAULT '',
    type VARCHAR NOT NULL DEFAULT 'Workshop',
    date DATE NOT NULL,
    mode VARCHAR NOT NULL DEFAULT 'Offline',
    registered INTEGER NOT NULL DEFAULT 0,
    seats INTEGER NOT NULL DEFAULT 50,
    status VARCHAR NOT NULL DEFAULT 'upcoming',
    image_color VARCHAR NOT NULL DEFAULT 'from-emerald-500 to-teal-600',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS public.articles (
    id SERIAL PRIMARY KEY,
    title VARCHAR NOT NULL,
    category VARCHAR NOT NULL DEFAULT 'General',
    author VARCHAR NOT NULL,
    content TEXT NOT NULL DEFAULT '',
    excerpt TEXT NOT NULL DEFAULT '',
    read_time VARCHAR NOT NULL DEFAULT '1 min read',
    status VARCHAR NOT NULL DEFAULT 'draft',
    published_at TIMESTAMP NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT articles_status_check CHECK (status IN ('published', 'draft', 'archived'))
);

CREATE TABLE IF NOT EXISTS public.users (
    id BIGSERIAL PRIMARY KEY,
    email TEXT NOT NULL UNIQUE,
    user_data JSONB NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Useful indexes for common list and join queries.
CREATE INDEX IF NOT EXISTS idx_applications_applicant_uid ON public.applications(applicant_uid);
CREATE INDEX IF NOT EXISTS idx_applications_opportunity_id ON public.applications(opportunity_id);
CREATE INDEX IF NOT EXISTS idx_opportunities_status_deadline ON public.opportunities(status, deadline);
CREATE INDEX IF NOT EXISTS idx_programs_status ON public.programs(status);
CREATE INDEX IF NOT EXISTS idx_events_date ON public.events(date);
CREATE INDEX IF NOT EXISTS idx_articles_status_published_at ON public.articles(status, published_at DESC);

-- Notes:
-- 1. `applications.applicant_uid` is a Firebase UID, not a users.id foreign key.
-- 2. Existing schema has no event-registration child table; `registered` is only a counter.
-- 3. `events` currently has no CHECK constraints for registered/seats/status/mode.
-- 4. `updated_at` defaults do not automatically update on every SQL UPDATE; application code
--    explicitly updates it for some modules. Consider a trigger for consistent enforcement.
