from typing import Any

from fastapi import APIRouter, HTTPException

from ..config import DEFAULT_USER_ID
from ..db import ensure_default_user, get_connection
from ..schemas.book import BookResponse, CreateBookRequest, UpdateBookRequest
from ..services.normalizers import (
    normalize_genre_name,
    normalize_series_name,
    normalize_status,
)

router = APIRouter()


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
                    format
                FROM books
                WHERE user_id = %s
                ORDER BY title ASC
                """,
                (DEFAULT_USER_ID,),
            )
            return cursor.fetchall()


@router.post("/books", response_model=BookResponse, status_code=201)
def create_book(payload: CreateBookRequest) -> dict[str, Any]:
    series_name = normalize_series_name(payload.series_id)
    genre_name = normalize_genre_name(payload.genre_id)
    if payload.volume is not None and series_name is None:
        raise HTTPException(
            status_code=400,
            detail="volume can only be set when series_id is provided",
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
                    series_id, volume, genre_id, age_category, release_date, format
                )
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
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
                    format
                """,
                (
                    DEFAULT_USER_ID,
                    payload.title.strip(),
                    payload.author.strip(),
                    normalize_status(payload.status),
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
                ),
            )
            return cursor.fetchone()


@router.put("/books/{book_id}", response_model=BookResponse)
def update_book(
    book_id: str,
    payload: UpdateBookRequest,
) -> dict[str, Any]:
    series_name = normalize_series_name(payload.series_id)
    genre_name = normalize_genre_name(payload.genre_id)
    if payload.volume is not None and series_name is None:
        raise HTTPException(
            status_code=400,
            detail="volume can only be set when series_id is provided",
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
                    format = %s
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
                    format
                """,
                (
                    payload.title.strip(),
                    payload.author.strip(),
                    normalize_status(payload.status),
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
                    book_id,
                    DEFAULT_USER_ID,
                ),
            )
            book = cursor.fetchone()

    if book is None:
        raise HTTPException(status_code=404, detail="Book not found")

    return book


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

