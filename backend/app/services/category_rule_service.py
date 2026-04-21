from sqlalchemy.orm import Session

from app.models.category_rule import CategoryRule
from app.models.category import Category
from app.schemas.category_rule import CategoryRuleCreate, CategoryRuleUpdate


def create_category_rule(db: Session, user_id: int, data: CategoryRuleCreate):
    category = (
        db.query(Category)
        .filter(Category.id == data.category_id, Category.user_id == user_id)
        .first()
    )
    if not category:
        return None, "Categoria não encontrada"

    rule = CategoryRule(
        keyword=data.keyword.strip().lower(),
        priority=data.priority,
        user_id=user_id,
        category_id=data.category_id,
    )

    db.add(rule)
    db.commit()
    db.refresh(rule)
    return rule, None


def get_category_rules(db: Session, user_id: int):
    return (
        db.query(CategoryRule)
        .filter(CategoryRule.user_id == user_id)
        .order_by(CategoryRule.priority.desc(), CategoryRule.id.asc())
        .all()
    )


def get_category_rule_by_id(db: Session, user_id: int, rule_id: int):
    return (
        db.query(CategoryRule)
        .filter(CategoryRule.id == rule_id, CategoryRule.user_id == user_id)
        .first()
    )


def update_category_rule(db: Session, user_id: int, rule: CategoryRule, data: CategoryRuleUpdate):
    category = (
        db.query(Category)
        .filter(Category.id == data.category_id, Category.user_id == user_id)
        .first()
    )
    if not category:
        return None, "Categoria não encontrada"

    rule.keyword = data.keyword.strip().lower()
    rule.priority = data.priority
    rule.category_id = data.category_id

    db.commit()
    db.refresh(rule)
    return rule, None


def delete_category_rule(db: Session, rule: CategoryRule):
    db.delete(rule)
    db.commit()