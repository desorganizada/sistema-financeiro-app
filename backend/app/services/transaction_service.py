from decimal import Decimal
from sqlalchemy.orm import Session
from sqlalchemy import extract

from app.models.transaction import Transaction
from app.models.account import Account
from app.models.category import Category
from app.models.user import User
from app.schemas.transaction import TransactionCreate, TransactionUpdate
from app.services.month_lock_service import is_month_closed
from app.services.currency_conversion_service import get_applicable_exchange_rate


def get_transactions(
    db: Session,
    user_id: int,
    transaction_type: str = None,
    category_id: int = None,
    account_id: int = None,
    month: int = None,
    year: int = None,
    limit: int = 20,
    offset: int = 0,
    sort_by: str = "date",
    sort_order: str = "desc",
):
    query = db.query(Transaction).filter(Transaction.user_id == user_id)

    if transaction_type:
        query = query.filter(Transaction.type == transaction_type)

    if category_id is not None:
        query = query.filter(Transaction.category_id == category_id)

    if account_id is not None:
        query = query.filter(Transaction.account_id == account_id)

    if month is not None:
        query = query.filter(extract("month", Transaction.date) == month)

    if year is not None:
        query = query.filter(extract("year", Transaction.date) == year)

    total = query.count()

    allowed_sort_fields = {
        "id": Transaction.id,
        "date": Transaction.date,
        "description": Transaction.description,
        "type": Transaction.type,
        "amount_original": Transaction.amount_original,
        "amount_converted": Transaction.amount_converted,
        "category_id": Transaction.category_id,
        "account_id": Transaction.account_id,
    }

    sort_column = allowed_sort_fields.get(sort_by, Transaction.date)

    if sort_order and sort_order.lower() == "asc":
        query = query.order_by(sort_column.asc())
    else:
        query = query.order_by(sort_column.desc())

    items = query.offset(offset).limit(limit).all()

    return {
        "items": items,
        "total": total,
        "limit": limit,
        "offset": offset,
    }


def get_transaction_by_id(db: Session, user_id: int, transaction_id: int):
    return (
        db.query(Transaction)
        .filter(Transaction.id == transaction_id, Transaction.user_id == user_id)
        .first()
    )


async def create_transaction(
    db: Session,
    user_id: int,
    transaction_data: TransactionCreate,
):
    year = transaction_data.date.year
    month = transaction_data.date.month

    if is_month_closed(db, user_id, year, month):
        return None, "Não é permitido criar transações em mês fechado"

    account = (
        db.query(Account)
        .filter(Account.id == transaction_data.account_id, Account.user_id == user_id)
        .first()
    )
    if not account:
        return None, "Conta não encontrada"

    category = (
        db.query(Category)
        .filter(Category.id == transaction_data.category_id, Category.user_id == user_id)
        .first()
    )
    if not category:
        return None, "Categoria não encontrada"

    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        return None, "Usuário não encontrado"

    exchange_rate, error = await get_applicable_exchange_rate(
        db=db,
        user=user,
        original_currency=transaction_data.original_currency,
        transaction_date=transaction_data.date,
        provided_exchange_rate=transaction_data.exchange_rate,
    )
    if error:
        return None, error

    amount_converted = (
        Decimal(str(transaction_data.amount_original)) *
        Decimal(str(exchange_rate))
    )

    transaction = Transaction(
        description=transaction_data.description,
        type=transaction_data.type,
        amount_original=transaction_data.amount_original,
        original_currency=transaction_data.original_currency.upper(),
        exchange_rate=exchange_rate,
        amount_converted=amount_converted,
        date=transaction_data.date,
        user_id=user_id,
        account_id=transaction_data.account_id,
        category_id=transaction_data.category_id,
    )

    db.add(transaction)
    db.commit()
    db.refresh(transaction)
    return transaction, None


async def update_transaction(
    db: Session,
    user: User,
    transaction: Transaction,
    transaction_data: TransactionUpdate,
):
    old_year = transaction.date.year
    old_month = transaction.date.month

    if is_month_closed(db, user.id, old_year, old_month):
        return None, "Não é permitido editar transações de mês fechado"

    new_year = transaction_data.date.year
    new_month = transaction_data.date.month

    if is_month_closed(db, user.id, new_year, new_month):
        return None, "Não é permitido mover transações para um mês fechado"

    account = (
        db.query(Account)
        .filter(Account.id == transaction_data.account_id, Account.user_id == user.id)
        .first()
    )
    if not account:
        return None, "Conta não encontrada"

    category = (
        db.query(Category)
        .filter(Category.id == transaction_data.category_id, Category.user_id == user.id)
        .first()
    )
    if not category:
        return None, "Categoria não encontrada"

    exchange_rate, error = await get_applicable_exchange_rate(
        db=db,
        user=user,
        original_currency=transaction_data.original_currency,
        transaction_date=transaction_data.date,
        provided_exchange_rate=transaction_data.exchange_rate,
    )
    if error:
        return None, error

    amount_converted = (
        Decimal(str(transaction_data.amount_original)) *
        Decimal(str(exchange_rate))
    )

    transaction.description = transaction_data.description
    transaction.type = transaction_data.type
    transaction.amount_original = transaction_data.amount_original
    transaction.original_currency = transaction_data.original_currency.upper()
    transaction.exchange_rate = exchange_rate
    transaction.amount_converted = amount_converted
    transaction.date = transaction_data.date
    transaction.account_id = transaction_data.account_id
    transaction.category_id = transaction_data.category_id

    db.commit()
    db.refresh(transaction)
    return transaction, None


def delete_transaction(db: Session, user_id: int, transaction: Transaction):
    year = transaction.date.year
    month = transaction.date.month

    if is_month_closed(db, user_id, year, month):
        return "Não é permitido excluir transações de mês fechado"

    db.delete(transaction)
    db.commit()
    return None