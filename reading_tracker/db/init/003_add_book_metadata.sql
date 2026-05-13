ALTER TABLE books
ADD COLUMN IF NOT EXISTS isbn TEXT,
ADD COLUMN IF NOT EXISTS pages INTEGER,
ADD COLUMN IF NOT EXISTS publisher TEXT,
ADD COLUMN IF NOT EXISTS language_code TEXT;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'books_pages_positive'
    ) THEN
        ALTER TABLE books
        ADD CONSTRAINT books_pages_positive CHECK (pages IS NULL OR pages > 0);
    END IF;
END $$;
