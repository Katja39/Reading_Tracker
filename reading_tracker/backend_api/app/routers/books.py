from datetime import date
from typing import Any

from fastapi import APIRouter, HTTPException

from ..config import DEFAULT_USER_ID
from ..db import ensure_default_user, get_connection
from ..schemas.book import (
    BookResponse,
    CreateBookRequest,
    CreateReadingProgressRequest,
    ReadingProgressResponse,
    UpdateBookRequest,
    UpdateReadingProgressRequest,
)
from ..services.normalizers import (
    normalize_genre_name,
    normalize_series_name,
    normalize_status,
)

router = APIRouter()

def _resolve_progress_date(value: str | None) -> str:
    if value is None:
        return date.today().isoformat()
    try:
        return date.fromisoformat(value).isoformat()
    except ValueError as error:
        raise HTTPException(
            status_code=400,
            detail="progress_date must use YYYY-MM-DD format",
        ) from error


def _refresh_book_current_page(cursor: Any, book_id: str) -> dict[str, Any]:
    cursor.execute(
        """
        UPDATE books
        SET currentPage = (
            SELECT page_number
            FROM reading_progress_entries
            WHERE book_id = %s AND user_id = %s
            ORDER BY progress_date DESC, updated_at DESC
            LIMIT 1
        )
        WHERE id = %s AND user_id = %s
        RETURNING
            id::text AS id,
            user_id::text AS user_id,
            title,
            author,
            status,
            rating,
            isbn,
            pages,
            publisher,
            language_code,
            cover_url,
            series_id,
            volume,
            genre_id,
            age_category,
            release_date::text AS release_date,
            format,
            description,
            currentPage AS "currentPage",
            reading_start_date::text AS reading_start_date,
            reading_end_date::text AS reading_end_date,
            created_at::text AS created_at,
            updated_at::text AS updated_at
        """,
        (book_id, DEFAULT_USER_ID, book_id, DEFAULT_USER_ID),
    )
    updated_book = cursor.fetchone()
    if updated_book is None:
        raise HTTPException(status_code=404, detail="Book not found")
    return updated_book

def _upsert_series(connection: Any, series_name: str) -> None:
    with connection.cursor() as cursor:
        cursor.execute(
            """
            INSERT INTO series (user_id, name)
            VALUES (%s, %s)
            ON CONFLICT (user_id, name) DO NOTHING
            """,
            (DEFAULT_USER_ID, series_name),
        )


def _upsert_genre(connection: Any, genre_name: str) -> None:
    with connection.cursor() as cursor:
        cursor.execute(
            """
            INSERT INTO genres (user_id, name, is_active)
            VALUES (%s, %s, true)
            ON CONFLICT (user_id, name)
            DO UPDATE SET is_active = EXCLUDED.is_active
            """,
            (DEFAULT_USER_ID, genre_name),
        )


@router.get("/books", response_model=list[BookResponse])
def list_books() -> list[dict[str, Any]]:
    with get_connection() as connection:
        ensure_default_user(connection)

        with connection.cursor() as cursor:
            cursor.execute(
                """
                SELECT
                    id::text AS id,
                    user_id::text AS user_id,
                    title,
                    author,
                    status,
                    rating,
                    isbn,
                    pages,
                    publisher,
                    language_code,
                    cover_url,
                    series_id,
                    volume,
                    genre_id,
                    age_category,
                    release_date::text AS release_date,
                    format,
                    description,
                    currentPage AS "currentPage",
                    reading_start_date::text AS reading_start_date,
                    reading_end_date::text AS reading_end_date,
                    created_at::text AS created_at,
                    updated_at::text AS updated_at
                FROM books
                WHERE user_id = %s
                ORDER BY title ASC
                """,
                (DEFAULT_USER_ID,),
            )
            return cursor.fetchall()


@router.post("/books", response_model=BookResponse, status_code=201)
def create_book(payload: CreateBookRequest) -> dict[str, Any]:
    status = normalize_status(payload.status)
    current_page = payload.currentPage if status == "reading" else None
    series_name = normalize_series_name(payload.series_id)
    genre_name = normalize_genre_name(payload.genre_id)
    if payload.volume is not None and series_name is None:
        raise HTTPException(
            status_code=400,
            detail="volume can only be set when series_id is provided",
        )
    if current_page is not None and payload.pages is not None and current_page > payload.pages:
        raise HTTPException(
            status_code=400,
            detail="currentPage must not be greater than pages",
        )

    with get_connection() as connection:
        ensure_default_user(connection)

        if series_name is not None:
            _upsert_series(connection, series_name)
        if genre_name is not None:
            _upsert_genre(connection, genre_name)

        with connection.cursor() as cursor:
            cursor.execute(
                """
                INSERT INTO books (
                    user_id, title, author, status, rating, isbn, pages, publisher, language_code, cover_url,
                    series_id, volume, genre_id, age_category, release_date, format,
                    description, currentPage, reading_start_date, reading_end_date
                )
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                RETURNING
                    id::text AS id,
                    user_id::text AS user_id,
                    title,
                    author,
                    status,
                    rating,
                    isbn,
                    pages,
                    publisher,
                    language_code,
                    cover_url,
                    series_id,
                    volume,
                    genre_id,
                    age_category,
                    release_date::text AS release_date,
                    format,
                    description,
                    currentPage AS "currentPage",
                    reading_start_date::text AS reading_start_date,
                    reading_end_date::text AS reading_end_date,
                    created_at::text AS created_at,
                    updated_at::text AS updated_at
                """,
                (
                    DEFAULT_USER_ID,
                    payload.title.strip(),
                    payload.author.strip(),
                    status,
                    payload.rating,
                    payload.isbn.strip() if payload.isbn else None,
                    payload.pages,
                    payload.publisher.strip() if payload.publisher else None,
                    payload.language_code.strip().lower() if payload.language_code else None,
                    payload.cover_url.strip() if payload.cover_url else None,
                    series_name,
                    payload.volume,
                    genre_name,
                    payload.age_category.strip().lower() if payload.age_category else None,
                    payload.release_date,
                    payload.format.strip().lower() if payload.format else None,
                    payload.description.strip() if payload.description else None,
                    current_page,
                    payload.reading_start_date,
                    payload.reading_end_date,
                ),
            )
            return cursor.fetchone()


@router.put("/books/{book_id}", response_model=BookResponse)
def update_book(
    book_id: str,
    payload: UpdateBookRequest,
) -> dict[str, Any]:
    status = normalize_status(payload.status)
    current_page = payload.currentPage if status == "reading" else None
    series_name = normalize_series_name(payload.series_id)
    genre_name = normalize_genre_name(payload.genre_id)
    if payload.volume is not None and series_name is None:
        raise HTTPException(
            status_code=400,
            detail="volume can only be set when series_id is provided",
        )
    if current_page is not None and payload.pages is not None and current_page > payload.pages:
        raise HTTPException(
            status_code=400,
            detail="currentPage must not be greater than pages",
        )

    with get_connection() as connection:
        if series_name is not None:
            _upsert_series(connection, series_name)
        if genre_name is not None:
            _upsert_genre(connection, genre_name)

        with connection.cursor() as cursor:
            cursor.execute(
                """
                UPDATE books
                SET title = %s,
                    author = %s,
                    status = %s,
                    rating = %s,
                    isbn = %s,
                    pages = %s,
                    publisher = %s,
                    language_code = %s,
                    cover_url = %s,
                    series_id = %s,
                    volume = %s,
                    genre_id = %s,
                    age_category = %s,
                    release_date = %s,
                    format = %s,
                    description = %s,
                    currentPage = %s,
                    reading_start_date = %s,
                    reading_end_date = %s
                WHERE id = %s AND user_id = %s
                RETURNING
                    id::text AS id,
                    user_id::text AS user_id,
                    title,
                    author,
                    status,
                    rating,
                    isbn,
                    pages,
                    publisher,
                    language_code,
                    cover_url,
                    series_id,
                    volume,
                    genre_id,
                    age_category,
                    release_date::text AS release_date,
                    format,
                    description,
                    currentPage AS "currentPage",
                    reading_start_date::text AS reading_start_date,
                    reading_end_date::text AS reading_end_date,
                    created_at::text AS created_at,
                    updated_at::text AS updated_at
                """,
                (
                    payload.title.strip(),
                    payload.author.strip(),
                    status,
                    payload.rating,
                    payload.isbn.strip() if payload.isbn else None,
                    payload.pages,
                    payload.publisher.strip() if payload.publisher else None,
                    payload.language_code.strip().lower() if payload.language_code else None,
                    payload.cover_url.strip() if payload.cover_url else None,
                    series_name,
                    payload.volume,
                    genre_name,
                    payload.age_category.strip().lower() if payload.age_category else None,
                    payload.release_date,
                    payload.format.strip().lower() if payload.format else None,
                    payload.description.strip() if payload.description else None,
                    current_page,
                    payload.reading_start_date,
                    payload.reading_end_date,
                    book_id,
                    DEFAULT_USER_ID,
                ),
            )
            book = cursor.fetchone()

    if book is None:
        raise HTTPException(status_code=404, detail="Book not found")

    return book


@router.get("/books/{book_id}/progress", response_model=list[ReadingProgressResponse])
def list_reading_progress(book_id: str) -> list[dict[str, Any]]:
    with get_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute(
                """
                SELECT 1
                FROM books
                WHERE id = %s AND user_id = %s
                """,
                (book_id, DEFAULT_USER_ID),
            )
            if cursor.fetchone() is None:
                raise HTTPException(status_code=404, detail="Book not found")

            cursor.execute(
                """
                SELECT
                    id::text AS id,
                    book_id::text AS book_id,
                    user_id::text AS user_id,
                    progress_date::text AS progress_date,
                    page_number,
                    created_at::text AS created_at,
                    updated_at::text AS updated_at
                FROM reading_progress_entries
                WHERE book_id = %s AND user_id = %s
                ORDER BY progress_date DESC, updated_at DESC
                """,
                (book_id, DEFAULT_USER_ID),
            )
            return cursor.fetchall()


@router.post("/books/{book_id}/progress", response_model=BookResponse)
def record_reading_progress(
    book_id: str,
    payload: CreateReadingProgressRequest,
) -> dict[str, Any]:
    progress_date = _resolve_progress_date(payload.progress_date)

    with get_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute(
                """
                SELECT status, pages
                FROM books
                WHERE id = %s AND user_id = %s
                """,
                (book_id, DEFAULT_USER_ID),
            )
            existing_book = cursor.fetchone()

            if existing_book is None:
                raise HTTPException(status_code=404, detail="Book not found")

            if existing_book["status"] != "reading":
                raise HTTPException(
                    status_code=400,
                    detail="reading progress can only be recorded for books with reading status",
                )

            total_pages = existing_book["pages"]
            if total_pages is not None and payload.page_number > total_pages:
                raise HTTPException(
                    status_code=400,
                    detail="page_number must not be greater than pages",
                )

            cursor.execute(
                """
                INSERT INTO reading_progress_entries (
                    book_id, user_id, progress_date, page_number
                )
                VALUES (%s, %s, %s, %s)
                ON CONFLICT (book_id, progress_date)
                DO UPDATE SET
                    user_id = EXCLUDED.user_id,
                    page_number = EXCLUDED.page_number
                """,
                (book_id, DEFAULT_USER_ID, progress_date, payload.page_number),
            )

            cursor.execute(
                """
                UPDATE books
                SET currentPage = (
                    SELECT page_number
                    FROM reading_progress_entries
                    WHERE book_id = %s AND user_id = %s
                    ORDER BY progress_date DESC, updated_at DESC
                    LIMIT 1
                )
                WHERE id = %s AND user_id = %s
                RETURNING
                    id::text AS id,
                    user_id::text AS user_id,
                    title,
                    author,
                    status,
                    rating,
                    isbn,
                    pages,
                    publisher,
                    language_code,
                    cover_url,
                    series_id,
                    volume,
                    genre_id,
                    age_category,
                    release_date::text AS release_date,
                    format,
                    description,
                    currentPage AS "currentPage",
                    reading_start_date::text AS reading_start_date,
                    reading_end_date::text AS reading_end_date,
                    created_at::text AS created_at,
                    updated_at::text AS updated_at
                """,
                (book_id, DEFAULT_USER_ID, book_id, DEFAULT_USER_ID),
            )
            updated_book = cursor.fetchone()

    if updated_book is None:
        raise HTTPException(status_code=404, detail="Book not found")

    return updated_book


@router.put("/books/{book_id}/progress/{progress_id}", response_model=BookResponse)
def update_reading_progress(
    book_id: str,
    progress_id: str,
    payload: UpdateReadingProgressRequest,
) -> dict[str, Any]:
    progress_date = _resolve_progress_date(payload.progress_date)

    with get_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute(
                """
                SELECT status, pages
                FROM books
                WHERE id = %s AND user_id = %s
                """,
                (book_id, DEFAULT_USER_ID),
            )
            existing_book = cursor.fetchone()
            if existing_book is None:
                raise HTTPException(status_code=404, detail="Book not found")
            if existing_book["status"] != "reading":
                raise HTTPException(
                    status_code=400,
                    detail="reading progress can only be updated for books with reading status",
                )

            total_pages = existing_book["pages"]
            if total_pages is not None and payload.page_number > total_pages:
                raise HTTPException(
                    status_code=400,
                    detail="page_number must not be greater than pages",
                )

            cursor.execute(
                """
                SELECT id
                FROM reading_progress_entries
                WHERE id = %s AND book_id = %s AND user_id = %s
                """,
                (progress_id, book_id, DEFAULT_USER_ID),
            )
            if cursor.fetchone() is None:
                raise HTTPException(status_code=404, detail="Progress entry not found")

            cursor.execute(
                """
                DELETE FROM reading_progress_entries
                WHERE book_id = %s
                  AND user_id = %s
                  AND progress_date = %s
                  AND id <> %s
                """,
                (book_id, DEFAULT_USER_ID, progress_date, progress_id),
            )
            cursor.execute(
                """
                UPDATE reading_progress_entries
                SET progress_date = %s,
                    page_number = %s
                WHERE id = %s AND book_id = %s AND user_id = %s
                """,
                (progress_date, payload.page_number, progress_id, book_id, DEFAULT_USER_ID),
            )
            return _refresh_book_current_page(cursor, book_id)


@router.delete("/books/{book_id}/progress/{progress_id}", response_model=BookResponse)
def delete_reading_progress(book_id: str, progress_id: str) -> dict[str, Any]:
    with get_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute(
                """
                DELETE FROM reading_progress_entries
                WHERE id = %s AND book_id = %s AND user_id = %s
                RETURNING id
                """,
                (progress_id, book_id, DEFAULT_USER_ID),
            )
            if cursor.fetchone() is None:
                raise HTTPException(status_code=404, detail="Progress entry not found")

            return _refresh_book_current_page(cursor, book_id)

@router.delete("/books/{book_id}", status_code=204)
def delete_book(book_id: str) -> None:
    with get_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute(
                """
                DELETE FROM books
                WHERE id = %s AND user_id = %s
                RETURNING id, series_id
                """,
                (book_id, DEFAULT_USER_ID),
            )
            deleted = cursor.fetchone()

            if deleted is not None and deleted.get("series_id") is not None:
                deleted_series = deleted["series_id"]
                cursor.execute(
                    """
                    SELECT 1
                    FROM books
                    WHERE user_id = %s AND series_id = %s
                    LIMIT 1
                    """,
                    (DEFAULT_USER_ID, deleted_series),
                )
                has_more = cursor.fetchone() is not None
                if not has_more:
                    cursor.execute(
                        """
                        DELETE FROM series
                        WHERE user_id = %s AND name = %s
                        """,
                        (DEFAULT_USER_ID, deleted_series),
                    )

    if deleted is None:
        raise HTTPException(status_code=404, detail="Book not found")




