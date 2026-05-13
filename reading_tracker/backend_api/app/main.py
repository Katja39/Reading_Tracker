from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from .routers import books, genres, health, metadata, series


app = FastAPI(title="Reading Tracker API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
app.include_router(health.router)
app.include_router(books.router)
app.include_router(metadata.router)
app.include_router(series.router)
app.include_router(genres.router)
