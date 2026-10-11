import os
from pymongo import MongoClient
from pymongo.errors import ConnectionFailure

MONGO_URI = os.getenv("MONGO_URI", "mongodb://localhost:27017/")
DB_NAME = os.getenv("DB_NAME", "overkill_todo")

client = MongoClient(MONGO_URI, serverSelectionTimeoutMS=3000)
db = client[DB_NAME]
todos_collection = db["todos"]


def ping_db() -> bool:
    """Used by /health to verify live DB connectivity."""
    try:
        client.admin.command("ping")
        return True
    except ConnectionFailure:
        return False