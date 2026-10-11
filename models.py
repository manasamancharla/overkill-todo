from pydantic import BaseModel, Field
from typing import Optional
from enum import Enum
from datetime import datetime, timezone


class Priority(str, Enum):
    low = "low"
    medium = "medium"
    high = "high"


class TodoCreate(BaseModel):
    """Payload for creating a new todo."""
    title: str = Field(..., min_length=1, max_length=200)
    priority: Priority = Priority.medium


class TodoUpdate(BaseModel):
    """Payload for updating a todo — all fields optional."""
    title: Optional[str] = Field(None, min_length=1, max_length=200)
    priority: Optional[Priority] = None
    done: Optional[bool] = None


class TodoResponse(BaseModel):
    """Shape returned to the client."""
    id: str
    title: str
    priority: Priority
    done: bool
    created_at: datetime

    class Config:
        populate_by_name = True


def todo_from_doc(doc: dict) -> TodoResponse:
    """Convert a MongoDB document to a TodoResponse."""
    return TodoResponse(
        id=str(doc["_id"]),
        title=doc["title"],
        priority=doc["priority"],
        done=doc["done"],
        created_at=doc["created_at"],
    )