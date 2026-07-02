import re
import urllib.parse
import urllib.request
from json import loads
from typing import Any

from ..config import OPEN_LIBRARY_USER_AGENT
from ..schemas.metadata import BookEnrichmentResponse
from .normalizers import normalize_isbn


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
    raw_code = key.rsplit("/", 1)[-1].lower() if "/" in key else key.lower()
    normalized_map = {
        "eng": "en",
        "deu": "de",
        "ger": "de",
    }
    return normalized_map.get(raw_code, raw_code)


def _first_subject(items: list[dict[str, Any]] | None) -> str | None:
    if not items:
        return None
    raw = items[0].get("name")
    if not isinstance(raw, str) or not raw.strip():
        return None
    return raw.strip()


def _to_slug(value: str | None) -> str | None:
    if value is None:
        return None
    slug = re.sub(r"[^a-z0-9]+", "_", value.lower()).strip("_")
    return slug if slug else None


def _text_value(value: Any) -> str | None:
    if isinstance(value, str) and value.strip():
        return value.strip()
    if isinstance(value, dict):
        raw_value = value.get("value")
        if isinstance(raw_value, str) and raw_value.strip():
            return raw_value.strip()
    if isinstance(value, list) and value:
        return _text_value(value[0])
    return None


def _description_from_details(details: dict[str, Any] | None) -> str | None:
    if details is None:
        return None
    return (
        _text_value(details.get("description"))
        or _text_value(details.get("first_sentence"))
    )


def _work_key_from_details(details: dict[str, Any] | None) -> str | None:
    if details is None:
        return None
    works = details.get("works")
    if isinstance(works, list) and works:
        work_key = works[0].get("key")
        if isinstance(work_key, str) and work_key.startswith("/works/"):
            return work_key
    return None


def _edition_json_url_from_item(item: dict[str, Any]) -> str | None:
    raw_url = item.get("url")
    if not isinstance(raw_url, str) or "/books/" not in raw_url:
        return None
    path = urllib.parse.urlparse(raw_url).path
    parts = [part for part in path.split("/") if part]
    if len(parts) < 2 or parts[0] != "books":
        return None
    return f"https://openlibrary.org/books/{urllib.parse.quote(parts[1])}.json"


def _fetch_json(url: str) -> dict[str, Any] | None:
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
    return payload if isinstance(payload, dict) else None


def _age_category_from_subject(subject: str | None) -> str | None:
    if subject is None:
        return None

    s = subject.lower()
    if "young adult" in s or "ya" in s:
        return "young_adult"
    if "middle grade" in s:
        return "middle_grade"
    if "new adult" in s:
        return "new_adult"
    if "children" in s or "juvenile" in s or "kids" in s:
        return "children"
    return None


def _release_date_iso(value: str | None) -> str | None:
    if value is None:
        return None
    stripped = value.strip()
    if re.match(r"^\d{4}-\d{2}-\d{2}$", stripped):
        return stripped
    year_match = re.search(r"\b(\d{4})\b", stripped)
    if year_match:
        return f"{year_match.group(1)}-01-01"
    return None


def _series_id(items: list[dict[str, Any]] | None) -> str | None:
    if not items:
        return None
    raw = items[0].get("name")
    if not isinstance(raw, str) or not raw.strip():
        return None
    return raw.strip()


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

    edition_details = _fetch_json(
        f"https://openlibrary.org/isbn/{urllib.parse.quote(normalized_isbn)}.json"
    )
    if edition_details is None:
        edition_json_url = _edition_json_url_from_item(item)
        if edition_json_url is not None:
            edition_details = _fetch_json(edition_json_url)

    description = _text_value(item.get("description"))
    if description is None:
        description = _description_from_details(edition_details)

    work_key = _work_key_from_details(edition_details)
    if description is None and work_key is not None:
        work_details = _fetch_json(f"https://openlibrary.org{work_key}.json")
        description = _description_from_details(work_details)

    pages = item.get("number_of_pages")
    pages_value = pages if isinstance(pages, int) and pages > 0 else None
    first_subject = _first_subject(item.get("subjects"))
    genre_id = _to_slug(first_subject)
    age_category = _age_category_from_subject(first_subject)
    release_date = _release_date_iso(item.get("publish_date"))
    series_id = _series_id(item.get("series"))
    physical_format = item.get("physical_format")
    book_format = _to_slug(physical_format) if isinstance(physical_format, str) else None
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
        series_id=series_id,
        genre_id=genre_id,
        age_category=age_category,
        release_date=release_date,
        format=book_format,
        description=description,
    )

