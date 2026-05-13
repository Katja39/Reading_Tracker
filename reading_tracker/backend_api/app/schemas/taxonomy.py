from pydantic import BaseModel, Field


class SeriesResponse(BaseModel):
    name: str


class CreateSeriesRequest(BaseModel):
    name: str = Field(min_length=1, max_length=255)


class GenreResponse(BaseModel):
    name: str


class CreateGenreRequest(BaseModel):
    name: str = Field(min_length=1, max_length=255)

