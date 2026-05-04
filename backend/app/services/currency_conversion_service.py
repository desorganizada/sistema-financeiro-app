from decimal import Decimal
from sqlalchemy.orm import Session

from app.models.exchange_rate import ExchangeRate
from app.models.user import User
from app.services.exchange_rate_sync_service import sync_exchange_rate_from_api


def _find_exchange_rate(
    db: Session,
    user_id: int,
    from_currency: str,
    to_currency: str,
    transaction_date,
):
    return (
        db.query(ExchangeRate)
        .filter(
            ExchangeRate.user_id == user_id,
            ExchangeRate.from_currency == from_currency,
            ExchangeRate.to_currency == to_currency,
            ExchangeRate.rate_date <= transaction_date,
        )
        .order_by(ExchangeRate.rate_date.desc(), ExchangeRate.id.desc())
        .first()
    )


async def get_applicable_exchange_rate(
    db: Session,
    user: User,
    original_currency: str,
    transaction_date,
    provided_exchange_rate=None,
):
    original_currency = original_currency.upper().strip()
    base_currency = user.base_currency.upper().strip()

    if original_currency == base_currency:
        return Decimal("1.0"), None

    if provided_exchange_rate is not None:
        return Decimal(str(provided_exchange_rate)), None

    # 1) Busca direta no banco
    direct_rate = _find_exchange_rate(
        db=db,
        user_id=user.id,
        from_currency=original_currency,
        to_currency=base_currency,
        transaction_date=transaction_date,
    )
    if direct_rate:
        return Decimal(str(direct_rate.rate)), None

    # 2) Busca inversa no banco
    inverse_rate = _find_exchange_rate(
        db=db,
        user_id=user.id,
        from_currency=base_currency,
        to_currency=original_currency,
        transaction_date=transaction_date,
    )
    if inverse_rate:
        inverse_value = Decimal(str(inverse_rate.rate))
        if inverse_value == 0:
            return None, (
                f"Cotação inversa inválida para "
                f"{base_currency} -> {original_currency}"
            )
        return Decimal("1") / inverse_value, None

    # 3) Tenta sincronizar da API o par direto
    synced_rate, sync_error = await sync_exchange_rate_from_api(
        db=db,
        user_id=user.id,
        from_currency=original_currency,
        to_currency=base_currency,
        rate_date=transaction_date,
    )
    if synced_rate:
        return Decimal(str(synced_rate.rate)), None

    # 4) Tenta sincronizar da API o par inverso
    inverse_synced_rate, inverse_sync_error = await sync_exchange_rate_from_api(
        db=db,
        user_id=user.id,
        from_currency=base_currency,
        to_currency=original_currency,
        rate_date=transaction_date,
    )
    if inverse_synced_rate:
        inverse_value = Decimal(str(inverse_synced_rate.rate))
        if inverse_value == 0:
            return None, (
                f"Cotação sincronizada inválida para "
                f"{base_currency} -> {original_currency}"
            )
        return Decimal("1") / inverse_value, None

    # 5) Retorna erro mais útil
    if sync_error:
        return None, sync_error

    if inverse_sync_error:
        return None, inverse_sync_error

    return None, f"Cotação não encontrada para {original_currency} -> {base_currency}"