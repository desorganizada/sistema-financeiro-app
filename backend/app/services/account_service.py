from decimal import Decimal
from datetime import date
from sqlalchemy.orm import Session

from app.models.account import Account
from app.models.transaction import Transaction
from app.models.category import Category
from app.models.user import User
from app.schemas.account import AccountCreate, AccountUpdate
from app.services.currency_conversion_service import get_applicable_exchange_rate


async def create_account(db: Session, user_id: int, account_data: AccountCreate):
    # Busca o usuário para saber a moeda base
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise ValueError("Usuário não encontrado")

    transaction_type = "investment" if account_data.type == "investimento" else "income"

    account = Account(
        name=account_data.name,
        type=account_data.type,
        currency=account_data.currency.upper(),
        user_id=user_id
    )
    db.add(account)
    db.commit()
    db.refresh(account)

    initial_balance = Decimal(str(account_data.initial_balance or 0))
    if initial_balance > 0:
        transaction_date = account_data.initial_balance_date or date.today()

        # --- CALCULA TAXA DE CÂMBIO (apenas para referência) ---
        exchange_rate = Decimal("1")
        amount_converted = initial_balance  # Mantém apenas para compatibilidade

        if account.currency != user.base_currency:
            rate, error = await get_applicable_exchange_rate(
                db=db,
                user=user,
                original_currency=account.currency,
                transaction_date=transaction_date,
                provided_exchange_rate=None
            )
            if error:
                raise Exception(error)
            exchange_rate = Decimal(str(rate))
            amount_converted = initial_balance * exchange_rate

        # Categoria "Saldo inicial"
        category = db.query(Category).filter(
            Category.user_id == user_id,
            Category.name == "Saldo inicial"
        ).first()
        if not category:
            category = Category(
                name="Saldo inicial",
                type="income",
                user_id=user_id
            )
            db.add(category)
            db.commit()
            db.refresh(category)

        # CRIA TRANSAÇÃO COM DADOS ORIGINAIS
        # O amount_converted é mantido para compatibilidade, mas NÃO será usado pelo dashboard
        initial_transaction = Transaction(
            user_id=user_id,
            account_id=account.id,
            category_id=category.id,
            type=transaction_type,
            description="Saldo inicial",
            amount_original=initial_balance,        # ← VALOR ORIGINAL (ex: 10 USD)
            original_currency=account.currency,     # ← MOEDA ORIGINAL (ex: USD)
            exchange_rate=exchange_rate,            # ← TAXA (apenas referência)
            amount_converted=amount_converted,      # ← Mantido para compatibilidade (NÃO usado no dashboard)
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


async def update_account(db: Session, account: Account, account_data: AccountUpdate):
    # Busca o usuário para saber a moeda base
    user = db.query(User).filter(User.id == account.user_id).first()
    if not user:
        raise ValueError("Usuário não encontrado")

    # Atualiza campos básicos
    account.name = account_data.name
    account.type = account_data.type
    account.currency = account_data.currency.upper()

    # Só processa o saldo inicial se o campo foi enviado
    if account_data.initial_balance is not None:
        initial_balance = Decimal(str(account_data.initial_balance))
        transaction_date = account_data.initial_balance_date or date.today()
        transaction_type = "investment" if account.type == "investimento" else "income"

        # --- CALCULA TAXA DE CÂMBIO (apenas para referência) ---
        exchange_rate = Decimal("1")
        amount_converted = initial_balance

        if account.currency != user.base_currency:
            rate, error = await get_applicable_exchange_rate(
                db=db,
                user=user,
                original_currency=account.currency,
                transaction_date=transaction_date,
                provided_exchange_rate=None
            )
            if error:
                raise Exception(error)
            exchange_rate = Decimal(str(rate))
            amount_converted = initial_balance * exchange_rate

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

        # Busca transação existente
        initial_transaction = db.query(Transaction).filter(
            Transaction.user_id == account.user_id,
            Transaction.account_id == account.id,
            Transaction.description == "Saldo inicial"
        ).first()

        if initial_balance > 0:
            if initial_transaction:
                initial_transaction.category_id = category.id
                initial_transaction.type = transaction_type
                initial_transaction.amount_original = initial_balance
                initial_transaction.original_currency = account.currency
                initial_transaction.exchange_rate = exchange_rate
                initial_transaction.amount_converted = amount_converted
                initial_transaction.date = transaction_date
            else:
                new_transaction = Transaction(
                    user_id=account.user_id,
                    account_id=account.id,
                    category_id=category.id,
                    type=transaction_type,
                    description="Saldo inicial",
                    amount_original=initial_balance,
                    original_currency=account.currency,
                    exchange_rate=exchange_rate,
                    amount_converted=amount_converted,
                    date=transaction_date,
                )
                db.add(new_transaction)
        else:
            if initial_transaction:
                db.delete(initial_transaction)

    db.commit()
    db.refresh(account)
    return account


def delete_account(db: Session, account: Account):
    """
    Exclui uma conta e todas as suas transações associadas
    """
    # 🔧 CORREÇÃO: Primeiro, exclui todas as transações da conta
    db.query(Transaction).filter(Transaction.account_id == account.id).delete()
    
    # Depois, exclui a conta
    db.delete(account)
    
    # Confirma as alterações no banco
    db.commit()


def get_account_balances(db: Session, user_id: int):
    """Este endpoint é para compatibilidade - usa amount_converted"""
    accounts = db.query(Account).filter(Account.user_id == user_id).all()
    result = []

    for account in accounts:
        transactions = db.query(Transaction).filter(
            Transaction.user_id == user_id,
            Transaction.account_id == account.id
        ).all()

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

        balance = income - expense + investment
        result.append({
            "account_id": account.id,
            "account_name": account.name,
            "currency": account.currency,
            "income": float(income),
            "expense": float(expense),
            "investment": float(investment),
            "balance": float(balance),
        })
    return result