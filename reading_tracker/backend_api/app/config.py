import os


DATABASE_URL = os.getenv("DATABASE_URL")
DEFAULT_USER_ID = os.getenv(
    "DEFAULT_USER_ID",
    "00000000-0000-0000-0000-000000000001",
)
ALLOWED_STATUSES = {
    "unread",
    "reading",
    "read",
    "paused",
    "dnf",
}
OPEN_LIBRARY_USER_AGENT = os.getenv(
    "OPEN_LIBRARY_USER_AGENT",
    "Reading_Tracker (contact@example.org)",
)

if not DATABASE_URL:
    raise RuntimeError("DATABASE_URL is not set")

