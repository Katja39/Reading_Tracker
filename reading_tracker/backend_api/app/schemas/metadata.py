from pydantic import BaseModel


class BookEnrichmentResponse(BaseModel):
    isbn: str
    title: str | None = None
    author: str | None = None
    pages: int | None = None
    publisher: str | None = None
    language_code: str | None = None
    cover_url: str | None = None
    series_id: str | None = None
    genre_id: str | None = None
    age_category: str | None = None
    release_date: str | None = None
    format: str | None = None
    description: str | None = None
    currentPage: int | None = None

