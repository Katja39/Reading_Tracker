from fastapi import APIRouter, HTTPException

from ..config import DEFAULT_USER_ID
from ..db import ensure_default_genres, ensure_default_user, get_connection
from ..schemas.taxonomy import CreateGenreRequest, GenreResponse
from ..services.normalizers import normalize_genre_name

router = APIRouter()


@router.get("/genres", response_model=list[GenreResponse])
def list_genres() -> list[dict[str, str]]:
    with get_connection() as connection:
        ensure_default_user(connection)
        ensure_default_genres(connection)
        with connection.cursor() as cursor:
            cursor.execute(
                """
                SELECT name
                FROM genres
                WHERE user_id = %s AND is_active = true
                ORDER BY name ASC
                """,
                (DEFAULT_USER_ID,),
            )
            return cursor.fetchall()


@router.post("/genres", response_model=GenreResponse, status_code=201)
def create_genre(payload: CreateGenreRequest) -> dict[str, str]:
    genre_name = normalize_genre_name(payload.name)
    if genre_name is None:
        raise HTTPException(status_code=400, detail="Genre name must not be empty")

    with get_connection() as connection:
        ensure_default_user(connection)
        with connection.cursor() as cursor:
            cursor.execute(
                """
                INSERT INTO genres (user_id, name, is_active)
                VALUES (%s, %s, true)
                ON CONFLICT (user_id, name)
                DO UPDATE SET is_active = EXCLUDED.is_active
                RETURNING name
                """,
                (DEFAULT_USER_ID, genre_name),
            )
            row = cursor.fetchone()
            if row is None:
                raise HTTPException(status_code=500, detail="Could not create genre")
            return row


@router.delete("/genres/{genre_name}", status_code=204)
def delete_genre(genre_name: str) -> None:
    normalized = normalize_genre_name(genre_name)
    if normalized is None:
        raise HTTPException(status_code=400, detail="Genre name must not be empty")

    with get_connection() as connection:
        ensure_default_user(connection)
        with connection.cursor() as cursor:
            cursor.execute(
                """
                UPDATE books
                SET genre_id = NULL
                WHERE user_id = %s AND genre_id = %s
                """,
                (DEFAULT_USER_ID, normalized),
            )
            cursor.execute(
                """
                INSERT INTO genres (user_id, name, is_active)
                VALUES (%s, %s, false)
                ON CONFLICT (user_id, name)
                DO UPDATE SET is_active = false
                """,
                (DEFAULT_USER_ID, normalized),
            )

