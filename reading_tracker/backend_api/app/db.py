import psycopg
from psycopg.rows import dict_row

from .config import DATABASE_URL, DEFAULT_USER_ID


def get_connection() -> psycopg.Connection:
    return psycopg.connect(
        DATABASE_URL,
        autocommit=True,
        row_factory=dict_row,
    )


def ensure_default_user(connection: psycopg.Connection) -> None:
    with connection.cursor() as cursor:
        cursor.execute(
            """
            INSERT INTO users (id)
            VALUES (%s)
            ON CONFLICT (id) DO NOTHING
            """,
            (DEFAULT_USER_ID,),
        )


def ensure_schema(connection: psycopg.Connection) -> None:
    statements = [
        """
        CREATE EXTENSION IF NOT EXISTS pgcrypto
        """,
        """
        CREATE TABLE IF NOT EXISTS users (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid()
        )
        """,
        """
        CREATE TABLE IF NOT EXISTS series (
            user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
            name TEXT NOT NULL,
            PRIMARY KEY (user_id, name)
        )
        """,
        """
        CREATE TABLE IF NOT EXISTS genres (
            user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
            name TEXT NOT NULL,
            is_active BOOLEAN NOT NULL DEFAULT true,
            PRIMARY KEY (user_id, name)
        )
        """,
        """
        CREATE TABLE IF NOT EXISTS books (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
            title TEXT NOT NULL,
            author TEXT NOT NULL,
            status TEXT NOT NULL DEFAULT 'unread',
            rating DOUBLE PRECISION
        )
        """,
        """
        ALTER TABLE books
        ADD COLUMN IF NOT EXISTS isbn TEXT,
        ADD COLUMN IF NOT EXISTS pages INTEGER,
        ADD COLUMN IF NOT EXISTS publisher TEXT,
        ADD COLUMN IF NOT EXISTS language_code TEXT,
        ADD COLUMN IF NOT EXISTS cover_url TEXT,
        ADD COLUMN IF NOT EXISTS series_id TEXT,
        ADD COLUMN IF NOT EXISTS volume INTEGER,
        ADD COLUMN IF NOT EXISTS genre_id TEXT,
        ADD COLUMN IF NOT EXISTS age_category TEXT,
        ADD COLUMN IF NOT EXISTS release_date DATE,
        ADD COLUMN IF NOT EXISTS format TEXT,
        ADD COLUMN IF NOT EXISTS description TEXT,
        ADD COLUMN IF NOT EXISTS reading_start_date DATE,
        ADD COLUMN IF NOT EXISTS reading_end_date DATE,
        ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
        ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
        """,
        """
        CREATE OR REPLACE FUNCTION set_books_updated_at()
        RETURNS TRIGGER AS $$
        BEGIN
            NEW.updated_at = now();
            RETURN NEW;
        END;
        $$ LANGUAGE plpgsql
        """,
        """
        DROP TRIGGER IF EXISTS trg_books_updated_at ON books
        """,
        """
        CREATE TRIGGER trg_books_updated_at
        BEFORE UPDATE ON books
        FOR EACH ROW
        EXECUTE FUNCTION set_books_updated_at()
        """,
        """
        CREATE INDEX IF NOT EXISTS idx_books_user_id ON books(user_id)
        """,
        """
        CREATE INDEX IF NOT EXISTS idx_books_user_title ON books(user_id, title)
        """,
    ]

    with connection.cursor() as cursor:
        for statement in statements:
            cursor.execute(statement)


def ensure_default_genres(connection: psycopg.Connection) -> None:
    default_genres = [
        "fantasy",
        "science_fiction",
        "romance",
        "thriller",
        "mystery",
        "horror",
        "historical_fiction",
        "non_fiction",
    ]
    with connection.cursor() as cursor:
        cursor.execute(
            """
            SELECT COUNT(*) AS count
            FROM genres
            WHERE user_id = %s
            """,
            (DEFAULT_USER_ID,),
        )
        row = cursor.fetchone()
        count = int(row["count"]) if row is not None else 0
        if count > 0:
            return

        for genre in default_genres:
            cursor.execute(
                """
                INSERT INTO genres (user_id, name, is_active)
                VALUES (%s, %s, true)
                ON CONFLICT (user_id, name)
                DO UPDATE SET is_active = EXCLUDED.is_active
                """,
                (DEFAULT_USER_ID, genre),
            )
