from fastapi import Depends, FastAPI, HTTPException, status
from sqlalchemy.orm import Session

from app import crud
from app.database import get_db
from app.schemas import ItemCreate, ItemResponse, ItemUpdate


app = FastAPI(
    title="V4 FastAPI CRUD Application",
    description="A simple FastAPI CRUD application with MySQL.",
    version="4.0.0",
)


@app.get("/")
def root():
    return {
        "message": "Hello, World!",
        "version": "4.0.0",
    }


@app.get("/health")
def health():
    return {
        "status": "healthy",
    }


@app.post(
    "/items",
    response_model=ItemResponse,
    status_code=status.HTTP_201_CREATED,
)
def create_item(
    item: ItemCreate,
    db: Session = Depends(get_db),
):
    return crud.create_item(db, item)


@app.get(
    "/items",
    response_model=list[ItemResponse],
)
def read_items(
    db: Session = Depends(get_db),
):
    return crud.get_items(db)


@app.get(
    "/items/{item_id}",
    response_model=ItemResponse,
)
def read_item(
    item_id: int,
    db: Session = Depends(get_db),
):
    item = crud.get_item(db, item_id)

    if item is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Item not found",
        )

    return item


@app.put(
    "/items/{item_id}",
    response_model=ItemResponse,
)
def update_item(
    item_id: int,
    item: ItemUpdate,
    db: Session = Depends(get_db),
):
    updated_item = crud.update_item(
        db,
        item_id,
        item,
    )

    if updated_item is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Item not found",
        )

    return updated_item


@app.delete(
    "/items/{item_id}",
    status_code=status.HTTP_204_NO_CONTENT,
)
def delete_item(
    item_id: int,
    db: Session = Depends(get_db),
):
    deleted_item = crud.delete_item(
        db,
        item_id,
    )

    if deleted_item is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Item not found",
        )

    return None