from decimal import Decimal
from datetime import date
from sqlalchemy.orm import Session

from app.models.account import Account
from app.models.transaction import Transaction
from app.models.category import Category
from app.schemas.account import AccountCreate, AccountUpdate


def create_account(db: Session, user_id: int, account_data: AccountCreate):
    # Mapeia o tipo da transação de acordo com o tipo da conta
    transaction_type = "investment" if account_data.type == "investimento" else "income"

    account = Account(
        name=account_data.name,
        type=account_data.type,
        currency=account_data.currency,
        user_id=user_id
    )

    db.add(account)
    db.commit()
    db.refresh(account)

    initial_balance = Decimal(str(account_data.initial_balance or 0))

    if initial_balance > 0:
        transaction_date = account_data.initial_balance_date or date.today()

        category = (
            db.query(Category)
            .filter(
                Category.user_id == user_id,
                Category.name == "Saldo inicial"
            )
            .first()
        )

        if not category:
            category = Category(
                name="Saldo inicial",
                type="income",
                user_id=user_id
            )
            db.add(category)
            db.commit()
            db.refresh(category)

        initial_transaction = Transaction(
            user_id=user_id,
            account_id=account.id,
            category_id=category.id,
            type=transaction_type,
            description="Saldo inicial",
            amount_converted=initial_balance,
            amount_original=initial_balance,
            original_currency=account.currency,
            exchange_rate=1,
            date=transaction_date,
        )

        db.add(initial_transaction)
        db.commit()

    return account


def get_accounts(db: Session, user_id: int):
    return db.query(Account).filter(Account.user_id == user_id).all()


def get_account_by_id(db: Session, user_id: int, account_id: int):
    return (
        db.query(Account)
        .filter(Account.id == account_id, Account.user_id == user_id)
        .first()
    )


def update_account(db: Session, account: Account, account_data: AccountUpdate):
    # Atualiza campos básicos (sempre)
    account.name = account_data.name
    account.type = account_data.type
    account.currency = account_data.currency

    # ============================================================
    # Só processa o saldo inicial SE o campo foi enviado (não None)
    # ============================================================
    if account_data.initial_balance is not None:
        initial_balance = Decimal(str(account_data.initial_balance))
        transaction_date = account_data.initial_balance_date or date.today()
        transaction_type = "investment" if account.type == "investimento" else "income"

        # Categoria "Saldo inicial"
        category = db.query(Category).filter(
            Category.user_id == account.user_id,
            Category.name == "Saldo inicial"
        ).first()
        if not category:
            category = Category(
                name="Saldo inicial",
                type="income",
                user_id=account.user_id
            )
            db.add(category)
            db.commit()
            db.refresh(category)

        # Busca transação existente de saldo inicial
        initial_transaction = db.query(Transaction).filter(
            Transaction.user_id == account.user_id,
            Transaction.account_id == account.id,
            Transaction.description == "Saldo inicial"
        ).first()

        if initial_balance > 0:
            if initial_transaction:
                # Atualiza a existente
                initial_transaction.category_id = category.id
                initial_transaction.type = transaction_type
                initial_transaction.amount_converted = initial_balance
                initial_transaction.amount_original = initial_balance
                initial_transaction.original_currency = account.currency
                initial_transaction.exchange_rate = 1
                initial_transaction.date = transaction_date
            else:
                # Cria nova
                new_transaction = Transaction(
                    user_id=account.user_id,
                    account_id=account.id,
                    category_id=category.id,
                    type=transaction_type,
                    description="Saldo inicial",
                    amount_converted=initial_balance,
                    amount_original=initial_balance,
                    original_currency=account.currency,
                    exchange_rate=1,
                    date=transaction_date,
                )
                db.add(new_transaction)
        else:
            # Se initial_balance == 0, remove a transação (se existir)
            if initial_transaction:
                db.delete(initial_transaction)

    db.commit()
    db.refresh(account)
    return account


def delete_account(db: Session, account: Account):
    db.delete(account)
    db.commit()


def get_account_balances(db: Session, user_id: int):
    accounts = db.query(Account).filter(Account.user_id == user_id).all()

    result = []

    for account in accounts:
        transactions = (
            db.query(Transaction)
            .filter(
                Transaction.user_id == user_id,
                Transaction.account_id == account.id
            )
            .all()
        )

        income = Decimal("0.00")
        expense = Decimal("0.00")
        investment = Decimal("0.00")

        for transaction in transactions:
            amount = Decimal(str(transaction.amount_converted or 0))

            if transaction.type == "income":
                income += amount
            elif transaction.type == "expense":
                expense += amount
            elif transaction.type == "investment":
                investment += amount

        # CORREÇÃO: investment soma, não subtrai
        balance = income - expense + investment

        result.append(
            {
                "account_id": account.id,
                "account_name": account.name,
                "currency": account.currency,
                "income": float(income),
                "expense": float(expense),
                "investment": float(investment),
                "balance": float(balance),
            }
        )

    return result