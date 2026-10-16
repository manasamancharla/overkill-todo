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

# Create Todo

@app.post("/create-todo", response_model=TodoResponse, status_code=201, tags=["todos"])
def create_todo(payload: TodoCreate):
    """Create a new todo."""
    doc = {
        "title": payload.title,
        "priority": payload.priority.value,
        "done": False,
        "created_at": datetime.now(timezone.utc),
    }
    result = todos_collection.insert_one(doc)
    doc["_id"] = result.inserted_id
    return todo_from_doc(doc)

# List Todos

@app.get("/todos", response_model=list[TodoResponse], tags=["todos"])
def list_todos(done: bool | None = None, priority: str | None = None):
    """
    List all todos.
    Optional query params: ?done=false  ?priority=high
    """
    query: dict = {}
    if done is not None:
        query["done"] = done
    if priority is not None:
        query["priority"] = priority
 
    docs = todos_collection.find(query).sort("created_at", -1)
    return [todo_from_doc(d) for d in docs]

# Update Todo

@app.put("/update-todo/{todo_id}", response_model=TodoResponse, tags=["todos"])
def update_todo(todo_id: str, payload: TodoUpdate):
    """Update title, priority, or done status of a todo."""
    if not ObjectId.is_valid(todo_id):
        raise HTTPException(status_code=400, detail="Invalid todo ID")
 
    updates = payload.model_dump(exclude_none=True)
    if not updates:
        raise HTTPException(status_code=400, detail="No fields to update")
 
    # Unwrap enum value if priority was passed
    if "priority" in updates:
        updates["priority"] = updates["priority"].value
 
    result = todos_collection.find_one_and_update(
        {"_id": ObjectId(todo_id)},
        {"$set": updates},
        return_document=True,
    )
    if result is None:
        raise HTTPException(status_code=404, detail="Todo not found")
    return todo_from_doc(result)

# Delete Todo

@app.delete("/todos/{todo_id}", status_code=204, tags=["todos"])
def delete_todo(todo_id: str):
    """Delete a todo by ID."""
    if not ObjectId.is_valid(todo_id):
        raise HTTPException(status_code=400, detail="Invalid todo ID")
 
    result = todos_collection.delete_one({"_id": ObjectId(todo_id)})
    if result.deleted_count == 0:
        raise HTTPException(status_code=404, detail="Todo not found")