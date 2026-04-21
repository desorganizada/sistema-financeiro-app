from sqlalchemy.orm import Session
from app.models.budget import Budget
from app.models.category import Category
from app.schemas.budget import BudgetCreate, BudgetUpdate


def create_budget(db: Session, user_id: int, budget_data: BudgetCreate):
    category = (
        db.query(Category)
        .filter(Category.id == budget_data.category_id, Category.user_id == user_id)
        .first()
    )

    if not category:
        return None, "Categoria não encontrada"

    existing_budget = (
        db.query(Budget)
        .filter(
            Budget.user_id == user_id,
            Budget.category_id == budget_data.category_id,
            Budget.year == budget_data.year,
            Budget.month == budget_data.month,
        )
        .first()
    )

    if existing_budget:
        return None, "Já existe orçamento para essa categoria nesse mês"

    budget = Budget(
        year=budget_data.year,
        month=budget_data.month,
        planned_amount=budget_data.planned_amount,
        user_id=user_id,
        category_id=budget_data.category_id,
    )

    db.add(budget)
    db.commit()
    db.refresh(budget)
    return budget, None


def get_budgets(db: Session, user_id: int, year: int, month: int):
    return (
        db.query(Budget)
        .filter(
            Budget.user_id == user_id,
            Budget.year == year,
            Budget.month == month,
        )
        .all()
    )


def get_budget_by_id(db: Session, user_id: int, budget_id: int):
    return (
        db.query(Budget)
        .filter(Budget.id == budget_id, Budget.user_id == user_id)
        .first()
    )


def update_budget(db: Session, user_id: int, budget: Budget, budget_data: BudgetUpdate):
    category = (
        db.query(Category)
        .filter(Category.id == budget_data.category_id, Category.user_id == user_id)
        .first()
    )

    if not category:
        return None, "Categoria não encontrada"

    budget.year = budget_data.year
    budget.month = budget_data.month
    budget.category_id = budget_data.category_id
    budget.planned_amount = budget_data.planned_amount

    db.commit()
    db.refresh(budget)
    return budget, None


def delete_budget(db: Session, budget: Budget):
    db.delete(budget)
    db.commit()