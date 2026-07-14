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
    currentPage: int | None = Field(default=None, ge=1, le=100000)
    reading_start_date: str | None = Field(default=None, max_length=10)
    reading_end_date: str | None = Field(default=None, max_length=10)
    how_acquired: str | None = Field(default=None, max_length=100)
    where_acquired: str | None = Field(default=None, max_length=255)
    author_origin_id: str | None = Field(default=None, max_length=255)
    author_gender: str | None = Field(default=None, max_length=50)
    acquired_on: str | None = Field(default=None, max_length=10)
    price: float | None = Field(default=None, ge=0)
    notes: str | None = Field(default=None, max_length=10000)
    total_reading_minutes: int | None = Field(default=None, ge=0, le=10000000)
    first_publish_year: int | None = Field(default=None, ge=0, le=9999)


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
    currentPage: int | None = Field(default=None, ge=1, le=100000)
    reading_start_date: str | None = Field(default=None, max_length=10)
    reading_end_date: str | None = Field(default=None, max_length=10)
    how_acquired: str | None = Field(default=None, max_length=100)
    where_acquired: str | None = Field(default=None, max_length=255)
    author_origin_id: str | None = Field(default=None, max_length=255)
    author_gender: str | None = Field(default=None, max_length=50)
    acquired_on: str | None = Field(default=None, max_length=10)
    price: float | None = Field(default=None, ge=0)
    notes: str | None = Field(default=None, max_length=10000)
    total_reading_minutes: int | None = Field(default=None, ge=0, le=10000000)
    first_publish_year: int | None = Field(default=None, ge=0, le=9999)


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
    currentPage: int | None
    reading_start_date: str | None
    reading_end_date: str | None
    how_acquired: str | None
    where_acquired: str | None
    author_origin_id: str | None
    author_gender: str | None
    acquired_on: str | None
    price: float | None
    notes: str | None
    total_reading_minutes: int | None
    first_publish_year: int | None
    created_at: str | None
    updated_at: str | None


class CreateReadingProgressRequest(BaseModel):
    page_number: int = Field(ge=0, le=100000)
    progress_date: str | None = Field(default=None, max_length=10)


class UpdateReadingProgressRequest(BaseModel):
    page_number: int = Field(ge=0, le=100000)
    progress_date: str = Field(min_length=10, max_length=10)


class ReadingProgressResponse(BaseModel):
    id: str
    book_id: str
    user_id: str
    progress_date: str
    page_number: int
    created_at: str | None
    updated_at: str | None
