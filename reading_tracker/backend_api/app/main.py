import os
import urllib.error
import urllib.parse
import urllib.request
from json import loads
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
OPEN_LIBRARY_USER_AGENT = os.getenv(
    "OPEN_LIBRARY_USER_AGENT",
    "Reading_Tracker (contact@example.org)",
)

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
    cover_url: str | None = Field(default=None, max_length=2048)


class UpdateBookRequest(BaseModel):
    title: str = Field(min_length=1, max_length=255)
    author: str = Field(min_length=1, max_length=255)
    status: str = Field(min_length=1, max_length=50)
    rating: float | None = Field(default=None, ge=0, le=5)
    isbn: str | None = Field(default=None, max_length=32)
    pages: int | None = Field(default=None, ge=1, le=100000)
    publisher: str | None = Field(default=None, max_length=255)
    language_code: str | None = Field(default=None, min_length=2, max_length=10)
    cover_url: str | None = Field(default=None, max_length=2048)


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
    cover_url: str | None


class BookEnrichmentResponse(BaseModel):
    isbn: str
    title: str | None = None
    author: str | None = None
    pages: int | None = None
    publisher: str | None = None
    language_code: str | None = None
    cover_url: str | None = None


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


def normalize_isbn(isbn: str) -> str:
    return isbn.strip().replace("-", "").replace(" ", "")


def _first_name(items: list[dict[str, Any]] | None) -> str | None:
    if not items:
        return None
    name = items[0].get("name")
    return name.strip() if isinstance(name, str) and name.strip() else None


def _language_code(items: list[dict[str, Any]] | None) -> str | None:
    if not items:
        return None
    key = items[0].get("key")
    if not isinstance(key, str):
        return None
    # Open Library often returns entries like "/languages/eng".
    if "/" in key:
        return key.rsplit("/", 1)[-1].lower()
    return key.lower()


def fetch_open_library_enrichment(isbn: str) -> BookEnrichmentResponse | None:
    normalized_isbn = normalize_isbn(isbn)
    if not normalized_isbn:
        return None

    query = urllib.parse.urlencode(
        {
            "bibkeys": f"ISBN:{normalized_isbn}",
            "format": "json",
            "jscmd": "data",
        }
    )
    url = f"https://openlibrary.org/api/books?{query}"
    request = urllib.request.Request(
        url,
        headers={
            "User-Agent": OPEN_LIBRARY_USER_AGENT,
            "Accept": "application/json",
        },
    )

    try:
        with urllib.request.urlopen(request, timeout=8) as response:
            payload = loads(response.read().decode("utf-8"))
    except Exception:
        return None

    key = f"ISBN:{normalized_isbn}"
    item = payload.get(key)
    if not isinstance(item, dict):
        return None

    pages = item.get("number_of_pages")
    pages_value = pages if isinstance(pages, int) and pages > 0 else None
    cover = item.get("cover")
    cover_url = None
    if isinstance(cover, dict):
        cover_url = cover.get("large") or cover.get("medium") or cover.get("small")
    if cover_url is None:
        cover_url = (
            f"https://covers.openlibrary.org/b/isbn/{normalized_isbn}-L.jpg?default=false"
        )

    return BookEnrichmentResponse(
        isbn=normalized_isbn,
        title=item.get("title"),
        author=_first_name(item.get("authors")),
        pages=pages_value,
        publisher=_first_name(item.get("publishers")),
        language_code=_language_code(item.get("languages")),
        cover_url=cover_url,
    )


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
                    language_code,
                    cover_url
                FROM books
                WHERE user_id = %s
                ORDER BY title ASC
                """,
                (DEFAULT_USER_ID,),
            )
            return cursor.fetchall()


@app.get("/isbn/enrich", response_model=BookEnrichmentResponse)
def enrich_by_isbn(isbn: str) -> BookEnrichmentResponse:
    enrichment = fetch_open_library_enrichment(isbn)
    if enrichment is None:
        raise HTTPException(
            status_code=404,
            detail="No Open Library metadata found for this ISBN",
        )
    return enrichment


@app.post("/books", response_model=BookResponse, status_code=201)
def create_book(payload: CreateBookRequest) -> dict[str, Any]:
    with get_connection() as connection:
        ensure_default_user(connection)

        with connection.cursor() as cursor:
            cursor.execute(
                """
                INSERT INTO books (
                    user_id, title, author, status, rating, isbn, pages, publisher, language_code, cover_url
                )
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
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
                    cover_url
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
                    language_code = %s,
                    cover_url = %s
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
                    cover_url
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
