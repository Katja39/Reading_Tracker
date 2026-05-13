import psycopg
from psycopg.rows import dict_row

from .config import DATABASE_URL, DEFAULT_USER_ID


def get_connection() -> psycopg.Connection:
    return psycopg.connect(
        DATABASE_URL,
        autocommit=True,
        row_factory=dict_row,
    )


def ensure_default_user(connection: psycopg.Connection) -> None:
    with connection.cursor() as cursor:
        cursor.execute(
            """
            INSERT INTO users (id)
            VALUES (%s)
            ON CONFLICT (id) DO NOTHING
            """,
            (DEFAULT_USER_ID,),
        )


def ensure_default_genres(connection: psycopg.Connection) -> None:
    default_genres = [
        "fantasy",
        "science_fiction",
        "romance",
        "thriller",
        "mystery",
        "horror",
        "historical_fiction",
        "non_fiction",
    ]
    with connection.cursor() as cursor:
        cursor.execute(
            """
            SELECT COUNT(*) AS count
            FROM genres
            WHERE user_id = %s
            """,
            (DEFAULT_USER_ID,),
        )
        row = cursor.fetchone()
        count = int(row["count"]) if row is not None else 0
        if count > 0:
            return

        for genre in default_genres:
            cursor.execute(
                """
                INSERT INTO genres (user_id, name, is_active)
                VALUES (%s, %s, true)
                ON CONFLICT (user_id, name)
                DO UPDATE SET is_active = EXCLUDED.is_active
                """,
                (DEFAULT_USER_ID, genre),
            )

