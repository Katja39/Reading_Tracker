from fastapi import HTTPException

from ..config import ALLOWED_STATUSES


def normalize_status(status: str) -> str:
    normalized_status = status.strip().lower()
    if normalized_status not in ALLOWED_STATUSES:
        raise HTTPException(status_code=400, detail="Invalid status")
    return normalized_status


def normalize_isbn(isbn: str) -> str:
    return isbn.strip().replace("-", "").replace(" ", "")


def normalize_series_name(name: str | None) -> str | None:
    if name is None:
        return None
    stripped = name.strip()
    return stripped if stripped else None


def normalize_genre_name(name: str | None) -> str | None:
    if name is None:
        return None
    stripped = name.strip()
    return stripped if stripped else None

