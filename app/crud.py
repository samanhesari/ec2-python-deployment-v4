from sqlalchemy.orm import Session

from app.models import Item
from app.schemas import ItemCreate, ItemUpdate


def create_item(db: Session, item: ItemCreate):
    db_item = Item(
        name=item.name,
        description=item.description,
        price=item.price,
    )

    db.add(db_item)
    db.commit()
    db.refresh(db_item)

    return db_item


def get_items(db: Session):
    return db.query(Item).all()


def get_item(db: Session, item_id: int):
    return db.query(Item).filter(Item.id == item_id).first()


def update_item(
    db: Session,
    item_id: int,
    item: ItemUpdate,
):
    db_item = get_item(db, item_id)

    if db_item is None:
        return None

    db_item.name = item.name
    db_item.description = item.description
    db_item.price = item.price

    db.commit()
    db.refresh(db_item)

    return db_item


def delete_item(db: Session, item_id: int):
    db_item = get_item(db, item_id)

    if db_item is None:
        return None

    db.delete(db_item)
    db.commit()

    return db_item