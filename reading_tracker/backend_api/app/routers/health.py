from fastapi import APIRouter

from ..db import get_connection

router = APIRouter()


@router.get("/health")
def healthcheck() -> dict[str, str]:
    with get_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute("SELECT 1")

    return {"status": "ok"}

