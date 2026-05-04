from decimal import Decimal
from sqlalchemy.orm import Session
from sqlalchemy import extract, func

from app.models.transaction import Transaction
from app.models.category import Category
from app.models.budget import Budget


def get_dashboard_summary(db: Session, user_id: int, year: int, month: int):
    transactions = (
        db.query(Transaction)
        .filter(
            Transaction.user_id == user_id,
            extract("year", Transaction.date) == year,
            extract("month", Transaction.date) == month,
        )
        .all()
    )

    income = Decimal("0.00")
    expense = Decimal("0.00")
    investment = Decimal("0.00")

    for transaction in transactions:
        if transaction.type == "income":
            income += Decimal(transaction.amount_converted)
        elif transaction.type == "expense":
            expense += Decimal(transaction.amount_converted)
        elif transaction.type == "investment":
            investment += Decimal(transaction.amount_converted)

    # 🔧 CORREÇÃO: Investimento SOMA ao invés de subtrair
    balance = income - expense + investment

    return {
        "year": year,
        "month": month,
        "income": float(income),
        "expense": float(expense),
        "investment": float(investment),
        "balance": float(balance),
        "transactions_count": len(transactions),
    }


def get_dashboard_by_category(db: Session, user_id: int, year: int, month: int):
    results = (
        db.query(
            Category.id.label("category_id"),
            Category.name.label("category_name"),
            Category.type.label("type"),
            func.coalesce(func.sum(Transaction.amount_converted), 0).label("total"),
        )
        .join(Transaction, Transaction.category_id == Category.id)
        .filter(
            Transaction.user_id == user_id,
            extract("year", Transaction.date) == year,
            extract("month", Transaction.date) == month,
        )
        .group_by(Category.id, Category.name, Category.type)
        .order_by(func.coalesce(func.sum(Transaction.amount_converted), 0).desc())
        .all()
    )

    return [
        {
            "category_id": int(row.category_id),
            "category_name": str(row.category_name),
            "type": str(row.type),
            "total": float(row.total or 0),
        }
        for row in results
    ]


def get_monthly_evolution(db: Session, user_id: int, year: int):
    transactions = (
        db.query(Transaction)
        .filter(
            Transaction.user_id == user_id,
            extract("year", Transaction.date) == year,
        )
        .all()
    )

    monthly_data = {
        month: {
            "month": month,
            "income": Decimal("0.00"),
            "expense": Decimal("0.00"),
            "investment": Decimal("0.00"),
            "balance": Decimal("0.00"),
        }
        for month in range(1, 13)
    }

    for transaction in transactions:
        month = transaction.date.month

        if transaction.type == "income":
            monthly_data[month]["income"] += Decimal(transaction.amount_converted)
        elif transaction.type == "expense":
            monthly_data[month]["expense"] += Decimal(transaction.amount_converted)
        elif transaction.type == "investment":
            monthly_data[month]["investment"] += Decimal(transaction.amount_converted)

    # 🔧 CORREÇÃO: Investimento SOMA ao invés de subtrair
    for month in range(1, 13):
        monthly_data[month]["balance"] = (
            monthly_data[month]["income"]
            - monthly_data[month]["expense"]
            + monthly_data[month]["investment"]  # ← MUDOU para +
        )

    return [
        {
            "month": data["month"],
            "income": float(data["income"]),
            "expense": float(data["expense"]),
            "investment": float(data["investment"]),
            "balance": float(data["balance"]),
        }
        for data in monthly_data.values()
    ]


def get_budget_vs_actual(db: Session, user_id: int, year: int, month: int):
    budgets = (
        db.query(Budget, Category)
        .join(Category, Budget.category_id == Category.id)
        .filter(
            Budget.user_id == user_id,
            Budget.year == year,
            Budget.month == month,
        )
        .all()
    )

    result = []

    for budget, category in budgets:
        actual_total = (
            db.query(func.coalesce(func.sum(Transaction.amount_converted), 0))
            .filter(
                Transaction.user_id == user_id,
                Transaction.category_id == budget.category_id,
                extract("year", Transaction.date) == year,
                extract("month", Transaction.date) == month,
            )
            .scalar()
        )

        planned = Decimal(str(budget.planned_amount))
        actual = Decimal(str(actual_total or 0))
        difference = planned - actual

        result.append(
            {
                "category_id": category.id,
                "category_name": category.name,
                "planned": float(planned),
                "actual": float(actual),
                "difference": float(difference),
            }
        )

    return result


def get_dashboard_percentages(db: Session, user_id: int, year: int, month: int):
    transactions = (
        db.query(Transaction)
        .filter(
            Transaction.user_id == user_id,
            extract("year", Transaction.date) == year,
            extract("month", Transaction.date) == month,
        )
        .all()
    )

    income = Decimal("0.00")
    expense = Decimal("0.00")
    investment = Decimal("0.00")

    for transaction in transactions:
        if transaction.type == "income":
            income += Decimal(transaction.amount_converted)
        elif transaction.type == "expense":
            expense += Decimal(transaction.amount_converted)
        elif transaction.type == "investment":
            investment += Decimal(transaction.amount_converted)

    # 🔧 CORREÇÃO: Investimento SOMA ao invés de subtrair
    balance = income - expense + investment

    if income > 0:
        expense_percentage = float((expense / income) * 100)
        investment_percentage = float((investment / income) * 100)
        balance_percentage = float((balance / income) * 100)
    else:
        expense_percentage = 0.0
        investment_percentage = 0.0
        balance_percentage = 0.0

    return {
        "year": year,
        "month": month,
        "income": float(income),
        "expense": float(expense),
        "investment": float(investment),
        "balance": float(balance),
        "expense_percentage": round(expense_percentage, 2),
        "investment_percentage": round(investment_percentage, 2),
        "balance_percentage": round(balance_percentage, 2),
    }