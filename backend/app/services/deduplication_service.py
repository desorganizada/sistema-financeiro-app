from decimal import Decimal
from sqlalchemy.orm import Session

from app.models.transaction import Transaction


def transaction_already_exists(
    db: Session,
    user_id: int,
    account_id: int,
    date,
    description: str,
    amount_original,
    transaction_type: str,
):
    normalized_description = description.strip().lower()

    existing_transactions = (
        db.query(Transaction)
        .filter(
            Transaction.user_id == user_id,
            Transaction.account_id == account_id,
            Transaction.date == date,
            Transaction.type == transaction_type,
            Transaction.amount_original == Decimal(amount_original),
        )
        .all()
    )

    for transaction in existing_transactions:
        if transaction.description.strip().lower() == normalized_description:
            return True

    return False