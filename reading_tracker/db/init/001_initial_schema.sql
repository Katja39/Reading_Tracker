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
    how_acquired TEXT,
    where_acquired TEXT,
    author_origin_id TEXT,
    author_gender TEXT,
    acquired_on DATE,
    price NUMERIC(10, 2),
    notes TEXT,
    total_reading_minutes INTEGER,
    first_publish_year INTEGER,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS reading_progress_entries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    book_id UUID NOT NULL REFERENCES books(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    progress_date DATE NOT NULL,
    page_number INTEGER NOT NULL CHECK (page_number >= 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT reading_progress_entries_book_date_unique UNIQUE (book_id, progress_date)
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
CREATE INDEX IF NOT EXISTS idx_reading_progress_entries_book_date
    ON reading_progress_entries(book_id, progress_date DESC);

ALTER TABLE books
    ADD COLUMN IF NOT EXISTS description TEXT,
    ADD COLUMN IF NOT EXISTS reading_start_date DATE,
    ADD COLUMN IF NOT EXISTS reading_end_date DATE,
    ADD COLUMN IF NOT EXISTS how_acquired TEXT,
    ADD COLUMN IF NOT EXISTS where_acquired TEXT,
    ADD COLUMN IF NOT EXISTS author_origin_id TEXT,
    ADD COLUMN IF NOT EXISTS author_gender TEXT,
    ADD COLUMN IF NOT EXISTS acquired_on DATE,
    ADD COLUMN IF NOT EXISTS price NUMERIC(10, 2),
    ADD COLUMN IF NOT EXISTS notes TEXT,
    ADD COLUMN IF NOT EXISTS total_reading_minutes INTEGER,
    ADD COLUMN IF NOT EXISTS first_publish_year INTEGER,
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

CREATE OR REPLACE FUNCTION set_reading_progress_entries_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_reading_progress_entries_updated_at ON reading_progress_entries;
CREATE TRIGGER trg_reading_progress_entries_updated_at
BEFORE UPDATE ON reading_progress_entries
FOR EACH ROW
EXECUTE FUNCTION set_reading_progress_entries_updated_at();
