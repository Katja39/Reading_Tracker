from fastapi import APIRouter, HTTPException

from ..config import DEFAULT_USER_ID
from ..db import ensure_default_user, get_connection
from ..schemas.taxonomy import CreateSeriesRequest, SeriesResponse
from ..services.normalizers import normalize_series_name

router = APIRouter()


@router.get("/series", response_model=list[SeriesResponse])
def list_series() -> list[dict[str, str]]:
    with get_connection() as connection:
        ensure_default_user(connection)
        with connection.cursor() as cursor:
            cursor.execute(
                """
                SELECT name
                FROM series
                WHERE user_id = %s
                ORDER BY name ASC
                """,
                (DEFAULT_USER_ID,),
            )
            return cursor.fetchall()


@router.post("/series", response_model=SeriesResponse, status_code=201)
def create_series(payload: CreateSeriesRequest) -> dict[str, str]:
    series_name = normalize_series_name(payload.name)
    if series_name is None:
        raise HTTPException(status_code=400, detail="Series name must not be empty")

    with get_connection() as connection:
        ensure_default_user(connection)
        with connection.cursor() as cursor:
            cursor.execute(
                """
                INSERT INTO series (user_id, name)
                VALUES (%s, %s)
                ON CONFLICT (user_id, name) DO NOTHING
                RETURNING name
                """,
                (DEFAULT_USER_ID, series_name),
            )
            created = cursor.fetchone()
            if created is not None:
                return created

            cursor.execute(
                """
                SELECT name
                FROM series
                WHERE user_id = %s AND name = %s
                """,
                (DEFAULT_USER_ID, series_name),
            )
            existing = cursor.fetchone()
            if existing is None:
                raise HTTPException(status_code=500, detail="Could not create series")
            return existing


@router.delete("/series/{series_name}", status_code=204)
def delete_series(series_name: str) -> None:
    normalized = normalize_series_name(series_name)
    if normalized is None:
        raise HTTPException(status_code=400, detail="Series name must not be empty")

    with get_connection() as connection:
        ensure_default_user(connection)
        with connection.cursor() as cursor:
            cursor.execute(
                """
                UPDATE books
                SET series_id = NULL, volume = NULL
                WHERE user_id = %s AND series_id = %s
                """,
                (DEFAULT_USER_ID, normalized),
            )
            cursor.execute(
                """
                DELETE FROM series
                WHERE user_id = %s AND name = %s
                """,
                (DEFAULT_USER_ID, normalized),
            )

