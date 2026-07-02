from pydantic import BaseModel, Field


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
    series_id: str | None = Field(default=None, max_length=255)
    volume: int | None = Field(default=None, ge=1, le=100000)
    genre_id: str | None = Field(default=None, max_length=255)
    age_category: str | None = Field(default=None, max_length=50)
    release_date: str | None = Field(default=None, max_length=10)
    format: str | None = Field(default=None, max_length=50)
    description: str | None = Field(default=None, max_length=10000)
    reading_start_date: str | None = Field(default=None, max_length=10)
    reading_end_date: str | None = Field(default=None, max_length=10)


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
    series_id: str | None = Field(default=None, max_length=255)
    volume: int | None = Field(default=None, ge=1, le=100000)
    genre_id: str | None = Field(default=None, max_length=255)
    age_category: str | None = Field(default=None, max_length=50)
    release_date: str | None = Field(default=None, max_length=10)
    format: str | None = Field(default=None, max_length=50)
    description: str | None = Field(default=None, max_length=10000)
    reading_start_date: str | None = Field(default=None, max_length=10)
    reading_end_date: str | None = Field(default=None, max_length=10)


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
    series_id: str | None
    volume: int | None
    genre_id: str | None
    age_category: str | None
    release_date: str | None
    format: str | None
    description: str | None
    reading_start_date: str | None
    reading_end_date: str | None
    created_at: str | None
    updated_at: str | None


