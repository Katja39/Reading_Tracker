import os
from typing import Any, List

import psycopg
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from psycopg.rows import dict_row


DATABASE_URL = os.getenv("DATABASE_URL")
DEFAULT_USER_ID = os.getenv(
    "DEFAULT_USER_ID",
    "00000000-0000-0000-0000-000000000001",
)
ALLOWED_STATUSES = {
    "unread",
    "reading",
    "read",
    "paused",
    "dnf",
}

if not DATABASE_URL:
    raise RuntimeError("DATABASE_URL is not set")


class CreateBookRequest(BaseModel):
    title: str = Field(min_length=1, max_length=255)
    author: str = Field(min_length=1, max_length=255)
    status: str = Field(min_length=1, max_length=50)
    rating: float | None = Field(default=None, ge=0, le=5)
    isbn: str | None = Field(default=None, max_length=32)
    pages: int | None = Field(default=None, ge=1, le=100000)
    publisher: str | None = Field(default=None, max_length=255)
    language_code: str | None = Field(default=None, min_length=2, max_length=10)


class UpdateBookRequest(BaseModel):
    title: str = Field(min_length=1, max_length=255)
    author: str = Field(min_length=1, max_length=255)
    status: str = Field(min_length=1, max_length=50)
    rating: float | None = Field(default=None, ge=0, le=5)
    isbn: str | None = Field(default=None, max_length=32)
    pages: int | None = Field(default=None, ge=1, le=100000)
    publisher: str | None = Field(default=None, max_length=255)
    language_code: str | None = Field(default=None, min_length=2, max_length=10)


class BookResponse(BaseModel):
    id: str
    user_id: str
    title: str
    author: str
    status: str
    rating: float | None
    isbn: str | None
    pages: int | None
    publisher: str | None
    language_code: str | None


app = FastAPI(title="Reading Tracker API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


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


def normalize_status(status: str) -> str:
    normalized_status = status.strip().lower()
    if normalized_status not in ALLOWED_STATUSES:
        raise HTTPException(status_code=400, detail="Invalid status")
    return normalized_status


@app.get("/health")
def healthcheck() -> dict[str, str]:
    with get_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute("SELECT 1")

    return {"status": "ok"}


@app.get("/books", response_model=List[BookResponse])
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
                    language_code
                FROM books
                WHERE user_id = %s
                ORDER BY title ASC
                """,
                (DEFAULT_USER_ID,),
            )
            return cursor.fetchall()


@app.post("/books", response_model=BookResponse, status_code=201)
def create_book(payload: CreateBookRequest) -> dict[str, Any]:
    with get_connection() as connection:
        ensure_default_user(connection)

        with connection.cursor() as cursor:
            cursor.execute(
                """
                INSERT INTO books (
                    user_id, title, author, status, rating, isbn, pages, publisher, language_code
                )
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
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
                    language_code
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
                ),
            )
            return cursor.fetchone()


@app.put("/books/{book_id}", response_model=BookResponse)
def update_book(
    book_id: str,
    payload: UpdateBookRequest,
) -> dict[str, Any]:
    with get_connection() as connection:
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
                    language_code = %s
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
                    language_code
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
                    book_id,
                    DEFAULT_USER_ID,
                ),
            )
            book = cursor.fetchone()

    if book is None:
        raise HTTPException(status_code=404, detail="Book not found")

    return book


@app.delete("/books/{book_id}", status_code=204)
def delete_book(book_id: str) -> None:
    with get_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute(
                """
                DELETE FROM books
                WHERE id = %s AND user_id = %s
                RETURNING id
                """,
                (book_id, DEFAULT_USER_ID),
            )
            deleted = cursor.fetchone()

    if deleted is None:
        raise HTTPException(status_code=404, detail="Book not found")
