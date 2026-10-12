from fastapi import FastAPI, HTTPException
from bson import ObjectId
from datetime import datetime, timezone
 
from mongodb_client import db, todos_collection, ping_db
from models import TodoCreate, TodoUpdate, TodoResponse, todo_from_doc
 
app = FastAPI(
    title="Overkill Todo",
    description="A todo app with three endpoints and a Zero Trust AWS architecture.",
    version="1.0.0",
)

# Health

@app.get("/health", tags=["ops"])
def health():
    """
    Liveness + DB connectivity check.
    Used by the ALB Target Group health check in AWS.
    Returns 200 only when MongoDB is reachable.
    """
    db_ok = ping_db()
    if not db_ok:
        raise HTTPException(status_code=503, detail="Database unreachable")
    return {"status": "ok", "database": "connected"}