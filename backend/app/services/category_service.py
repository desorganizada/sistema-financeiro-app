from sqlalchemy.orm import Session
from app.models.category import Category
from app.schemas.category import CategoryCreate, CategoryUpdate


def create_category(db: Session, user_id: int, category_data: CategoryCreate):
    category = Category(
        name=category_data.name,
        type=category_data.type,
        group_name=category_data.group_name,
        user_id=user_id
    )

    db.add(category)
    db.commit()
    db.refresh(category)
    return category


def get_categories(db: Session, user_id: int):
    return db.query(Category).filter(Category.user_id == user_id).all()


def get_category_by_id(db: Session, user_id: int, category_id: int):
    return (
        db.query(Category)
        .filter(Category.id == category_id, Category.user_id == user_id)
        .first()
    )


def update_category(db: Session, category: Category, category_data: CategoryUpdate):
    category.name = category_data.name
    category.type = category_data.type
    category.group_name = category_data.group_name

    db.commit()
    db.refresh(category)
    return category


def delete_category(db: Session, category: Category):
    db.delete(category)
    db.commit()