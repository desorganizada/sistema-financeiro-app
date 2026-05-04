import tempfile
from decimal import Decimal

from ofxtools.Parser import OFXTree
from sqlalchemy.orm import Session

from app.models.transaction import Transaction
from app.models.account import Account
from app.models.category import Category
from app.services.deduplication_service import transaction_already_exists
from app.services.month_lock_service import is_month_closed
from app.services.auto_categorization_service import find_category_id_by_description


def import_transactions_from_ofx(
    db: Session,
    user_id: int,
    file_content: bytes,
    account_id: int,
    category_id: int,
):
    account = (
        db.query(Account)
        .filter(Account.id == account_id, Account.user_id == user_id)
        .first()
    )
    if not account:
        return {
            "created_count": 0,
            "skipped_count": 0,
            "errors_count": 1,
            "errors": [f"Conta {account_id} não encontrada"]
        }

    category = (
        db.query(Category)
        .filter(Category.id == category_id, Category.user_id == user_id)
        .first()
    )
    if not category:
        return {
            "created_count": 0,
            "skipped_count": 0,
            "errors_count": 1,
            "errors": [f"Categoria {category_id} não encontrada"]
        }

    created_transactions = []
    errors = []
    skipped_count = 0

    with tempfile.NamedTemporaryFile(delete=False, suffix=".ofx") as tmp:
        tmp.write(file_content)
        tmp_path = tmp.name

    try:
        parser = OFXTree()
        parser.parse(tmp_path)
        ofx = parser.convert()

        bank_messages = getattr(ofx, "bankmsgsrsv1", None)
        if not bank_messages:
            return {
                "created_count": 0,
                "skipped_count": 0,
                "errors_count": 1,
                "errors": ["Arquivo OFX sem bankmsgsrsv1"]
            }

        stmttrnrs = getattr(bank_messages, "stmttrnrs", None)
        if not stmttrnrs or not getattr(stmttrnrs, "stmtrs", None):
            return {
                "created_count": 0,
                "skipped_count": 0,
                "errors_count": 1,
                "errors": ["Arquivo OFX sem extrato válido"]
            }

        stmtrs = stmttrnrs.stmtrs
        banktranlist = getattr(stmtrs, "banktranlist", None)
        if not banktranlist or not getattr(banktranlist, "stmttrn", None):
            return {
                "created_count": 0,
                "skipped_count": 0,
                "errors_count": 1,
                "errors": ["Arquivo OFX sem transações"]
            }

        currency = getattr(stmtrs, "curdef", None) or "BRL"
        transactions = banktranlist.stmttrn

        for index, trx in enumerate(transactions, start=1):
            try:
                amount_original = Decimal(str(abs(trx.trnamt)))
                transaction_type = "income" if trx.trnamt > 0 else "expense"
                transaction_date = trx.dtposted.date()
                description = getattr(trx, "name", None) or getattr(trx, "memo", None) or "Transação OFX"

                detected_category_id = find_category_id_by_description(db, user_id, description)
                final_category_id = detected_category_id or category_id

                if is_month_closed(db, user_id, transaction_date.year, transaction_date.month):
                    errors.append(
                        f"Transação {index}: mês {transaction_date.month}/{transaction_date.year} está fechado"
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
                    original_currency=currency,
                    exchange_rate=Decimal("1.0"),
                    amount_converted=amount_original,
                    date=transaction_date,
                    user_id=user_id,
                    account_id=account_id,
                    category_id=final_category_id,
                )

                db.add(transaction)
                created_transactions.append(transaction)

            except Exception as e:
                errors.append(f"Transação {index}: erro ao processar ({str(e)})")

        db.commit()

        for transaction in created_transactions:
            db.refresh(transaction)

        return {
            "created_count": len(created_transactions),
            "skipped_count": skipped_count,
            "errors_count": len(errors),
            "errors": errors,
        }

    except Exception as e:
        return {
            "created_count": 0,
            "skipped_count": 0,
            "errors_count": 1,
            "errors": [f"Erro ao ler OFX: {str(e)}"]
        }