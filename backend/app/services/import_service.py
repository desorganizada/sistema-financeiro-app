import csv
import io
from decimal import Decimal
from datetime import datetime

from sqlalchemy.orm import Session

from app.models.transaction import Transaction
from app.models.account import Account
from app.models.category import Category
from app.services.deduplication_service import transaction_already_exists
from app.services.month_lock_service import is_month_closed
from app.services.auto_categorization_service import find_category_id_by_description


def import_transactions_from_csv(db: Session, user_id: int, file_content: bytes):
    decoded_file = file_content.decode("utf-8")
    csv_reader = csv.DictReader(io.StringIO(decoded_file))

    created_transactions = []
    errors = []
    skipped_count = 0

    for index, row in enumerate(csv_reader, start=2):
        try:
            account_id = int(row["account_id"])
            description = row["description"]

            account = (
                db.query(Account)
                .filter(Account.id == account_id, Account.user_id == user_id)
                .first()
            )
            if not account:
                errors.append(f"Linha {index}: conta {account_id} não encontrada")
                continue

            raw_category_id = row.get("category_id")

            if raw_category_id:
                category_id = int(raw_category_id)

                category = (
                    db.query(Category)
                    .filter(Category.id == category_id, Category.user_id == user_id)
                    .first()
                )
                if not category:
                    errors.append(f"Linha {index}: categoria {category_id} não encontrada")
                    continue
            else:
                category_id = find_category_id_by_description(db, user_id, description)
                if not category_id:
                    errors.append(
                        f"Linha {index}: categoria não informada e nenhuma regra encontrada"
                    )
                    continue

            amount_original = Decimal(row["amount_original"])
            exchange_rate = Decimal(row["exchange_rate"])
            amount_converted = amount_original * exchange_rate
            transaction_date = datetime.strptime(row["date"], "%Y-%m-%d").date()
            transaction_type = row["type"]

            if is_month_closed(db, user_id, transaction_date.year, transaction_date.month):
                errors.append(
                    f"Linha {index}: mês {transaction_date.month}/{transaction_date.year} está fechado"
                )
                continue

            if transaction_already_exists(
                db=db,
                user_id=user_id,
                account_id=account_id,
                date=transaction_date,
                description=description,
                amount_original=amount_original,
                transaction_type=transaction_type,
            ):
                skipped_count += 1
                continue

            transaction = Transaction(
                description=description,
                type=transaction_type,
                amount_original=amount_original,
                original_currency=row["original_currency"],
                exchange_rate=exchange_rate,
                amount_converted=amount_converted,
                date=transaction_date,
                user_id=user_id,
                account_id=account_id,
                category_id=category_id,
            )

            db.add(transaction)
            created_transactions.append(transaction)

        except Exception as e:
            errors.append(f"Linha {index}: erro ao processar ({str(e)})")

    db.commit()

    for transaction in created_transactions:
        db.refresh(transaction)

    return {
        "created_count": len(created_transactions),
        "skipped_count": skipped_count,
        "errors_count": len(errors),
        "errors": errors,
    }