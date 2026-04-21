from sqlalchemy.orm import Session

from app.models.category_rule import CategoryRule


def find_category_id_by_description(db: Session, user_id: int, description: str):
    normalized_description = description.strip().lower()

    rules = (
        db.query(CategoryRule)
        .filter(CategoryRule.user_id == user_id)
        .order_by(CategoryRule.priority.desc(), CategoryRule.id.asc())
        .all()
    )

    for rule in rules:
        if rule.keyword in normalized_description:
            return rule.category_id

    return None