from decimal import Decimal
from sqlalchemy.orm import Session
from sqlalchemy import extract

from app.models.transaction import Transaction
from app.models.monthly_closure import MonthlyClosure


def get_monthly_closure(db: Session, user_id: int, year: int, month: int):
    return (
        db.query(MonthlyClosure)
        .filter(
            MonthlyClosure.user_id == user_id,
            MonthlyClosure.year == year,
            MonthlyClosure.month == month,
        )
        .first()
    )


def close_month(db: Session, user_id: int, year: int, month: int):
    existing_closure = get_monthly_closure(db, user_id, year, month)
    if existing_closure:
        return None, "Este mês já foi fechado"

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
        amount = Decimal(transaction.amount_converted)

        if transaction.type == "income":
            income += amount
        elif transaction.type == "expense":
            expense += amount
        elif transaction.type == "investment":
            investment += amount

    balance = income - expense - investment

    closure = MonthlyClosure(
        year=year,
        month=month,
        income=income,
        expense=expense,
        investment=investment,
        balance=balance,
        transactions_count=len(transactions),
        user_id=user_id,
    )

    db.add(closure)
    db.commit()
    db.refresh(closure)

    return closure, None


def reopen_month(db: Session, user_id: int, year: int, month: int):
    closure = get_monthly_closure(db, user_id, year, month)

    if not closure:
        return "Fechamento mensal não encontrado"

    db.delete(closure)
    db.commit()

    return None