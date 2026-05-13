from fastapi import APIRouter, HTTPException

from ..schemas.metadata import BookEnrichmentResponse
from ..services.open_library import fetch_open_library_enrichment

router = APIRouter()


@router.get("/isbn/enrich", response_model=BookEnrichmentResponse)
def enrich_by_isbn(isbn: str) -> BookEnrichmentResponse:
    enrichment = fetch_open_library_enrichment(isbn)
    if enrichment is None:
        raise HTTPException(
            status_code=404,
            detail="No Open Library metadata found for this ISBN",
        )
    return enrichment

