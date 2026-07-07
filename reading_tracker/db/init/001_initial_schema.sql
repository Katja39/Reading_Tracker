CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid()
);

CREATE TABLE IF NOT EXISTS books (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    author TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'unread',
    rating DOUBLE PRECISION,
    isbn TEXT,
    pages INTEGER,
    publisher TEXT,
    language_code TEXT,
    cover_url TEXT,
    series_id TEXT,
    volume INTEGER,
    genre_id TEXT,
    age_category TEXT,
    release_date DATE,
    format TEXT,
    description TEXT,
    currentPage INTEGER,
    reading_start_date DATE,
    reading_end_date DATE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS series (
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    PRIMARY KEY (user_id, name)
);

CREATE TABLE IF NOT EXISTS genres (
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT true,
    PRIMARY KEY (user_id, name)
);

CREATE INDEX IF NOT EXISTS idx_books_user_id ON books(user_id);
CREATE INDEX IF NOT EXISTS idx_books_user_title ON books(user_id, title);

ALTER TABLE books
    ADD COLUMN IF NOT EXISTS description TEXT,
    ADD COLUMN IF NOT EXISTS reading_start_date DATE,
    ADD COLUMN IF NOT EXISTS reading_end_date DATE,
    ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT now();

CREATE OR REPLACE FUNCTION set_books_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_books_updated_at ON books;
CREATE TRIGGER trg_books_updated_at
BEFORE UPDATE ON books
FOR EACH ROW
EXECUTE FUNCTION set_books_updated_at();
