from datetime import date
from decimal import Decimal, ROUND_HALF_UP
from sqlalchemy.orm import Session

from app.models.exchange_rate import ExchangeRate
from app.schemas.exchange_rate import ExchangeRateCreate, ExchangeRateUpdate
from app.services.exchange_rate_sync_service import sync_exchange_rate_from_api


def _round_money(value: Decimal) -> Decimal:
    return Decimal(value).quantize(Decimal("0.01"), rounding=ROUND_HALF_UP)


def _round_rate(value: Decimal) -> Decimal:
    return Decimal(value).quantize(Decimal("0.000000"), rounding=ROUND_HALF_UP)


def _normalize_currency(value: str) -> str:
    return value.upper().strip()


def _find_exchange_rate(
    db: Session,
    user_id: int,
    from_currency: str,
    to_currency: str,
    rate_date: date | None = None,
):
    query = db.query(ExchangeRate).filter(
        ExchangeRate.user_id == user_id,
        ExchangeRate.from_currency == _normalize_currency(from_currency),
        ExchangeRate.to_currency == _normalize_currency(to_currency),
    )

    if rate_date:
        query = query.filter(ExchangeRate.rate_date <= rate_date)

    return query.order_by(
        ExchangeRate.rate_date.desc(),
        ExchangeRate.id.desc(),
    ).first()


def create_exchange_rate(db: Session, user_id: int, data: ExchangeRateCreate):
    from_currency = _normalize_currency(data.from_currency)
    to_currency = _normalize_currency(data.to_currency)

    existing = (
        db.query(ExchangeRate)
        .filter(
            ExchangeRate.user_id == user_id,
            ExchangeRate.from_currency == from_currency,
            ExchangeRate.to_currency == to_currency,
            ExchangeRate.rate_date == data.rate_date,
        )
        .first()
    )

    if existing:
        return None, "Já existe cotação para esse par de moedas nessa data"

    exchange_rate = ExchangeRate(
        from_currency=from_currency,
        to_currency=to_currency,
        rate=data.rate,
        rate_date=data.rate_date,
        user_id=user_id,
    )

    db.add(exchange_rate)
    db.commit()
    db.refresh(exchange_rate)
    return exchange_rate, None


def get_exchange_rates(
    db: Session,
    user_id: int,
    from_currency: str | None = None,
    to_currency: str | None = None,
    rate_date: date | None = None,
):
    query = db.query(ExchangeRate).filter(ExchangeRate.user_id == user_id)

    if from_currency:
        query = query.filter(
            ExchangeRate.from_currency == _normalize_currency(from_currency)
        )

    if to_currency:
        query = query.filter(
            ExchangeRate.to_currency == _normalize_currency(to_currency)
        )

    if rate_date:
        query = query.filter(ExchangeRate.rate_date == rate_date)

    return query.order_by(
        ExchangeRate.rate_date.desc(),
        ExchangeRate.id.desc(),
    ).all()


def get_exchange_rate_by_id(db: Session, user_id: int, exchange_rate_id: int):
    return (
        db.query(ExchangeRate)
        .filter(
            ExchangeRate.id == exchange_rate_id,
            ExchangeRate.user_id == user_id,
        )
        .first()
    )


def get_latest_exchange_rate(
    db: Session,
    user_id: int,
    from_currency: str,
    to_currency: str,
):
    return (
        db.query(ExchangeRate)
        .filter(
            ExchangeRate.user_id == user_id,
            ExchangeRate.from_currency == _normalize_currency(from_currency),
            ExchangeRate.to_currency == _normalize_currency(to_currency),
        )
        .order_by(
            ExchangeRate.rate_date.desc(),
            ExchangeRate.id.desc(),
        )
        .first()
    )


def update_exchange_rate(
    db: Session,
    exchange_rate: ExchangeRate,
    data: ExchangeRateUpdate,
):
    exchange_rate.from_currency = _normalize_currency(data.from_currency)
    exchange_rate.to_currency = _normalize_currency(data.to_currency)
    exchange_rate.rate = data.rate
    exchange_rate.rate_date = data.rate_date

    db.commit()
    db.refresh(exchange_rate)
    return exchange_rate


def delete_exchange_rate(db: Session, exchange_rate: ExchangeRate):
    db.delete(exchange_rate)
    db.commit()


async def convert_currency(
    db: Session,
    user_id: int,
    amount: Decimal,
    from_currency: str,
    to_currency: str,
    rate_date: date | None = None,
    auto_sync: bool = True,
):
    from_currency = _normalize_currency(from_currency)
    to_currency = _normalize_currency(to_currency)
    amount = Decimal(str(amount))

    if from_currency == to_currency:
        effective_date = rate_date or date.today()
        return {
            "amount": _round_money(amount),
            "from_currency": from_currency,
            "to_currency": to_currency,
            "exchange_rate": Decimal("1.000000"),
            "converted_amount": _round_money(amount),
            "rate_date_used": effective_date,
            "auto_synced": False,
        }, None

    direct_rate = _find_exchange_rate(
        db=db,
        user_id=user_id,
        from_currency=from_currency,
        to_currency=to_currency,
        rate_date=rate_date,
    )

    if direct_rate:
        rate_value = Decimal(str(direct_rate.rate))
        converted_amount = amount * rate_value

        return {
            "amount": _round_money(amount),
            "from_currency": from_currency,
            "to_currency": to_currency,
            "exchange_rate": _round_rate(rate_value),
            "converted_amount": _round_money(converted_amount),
            "rate_date_used": direct_rate.rate_date,
            "auto_synced": False,
        }, None

    inverse_rate = _find_exchange_rate(
        db=db,
        user_id=user_id,
        from_currency=to_currency,
        to_currency=from_currency,
        rate_date=rate_date,
    )

    if inverse_rate:
        inverse_value = Decimal(str(inverse_rate.rate))

        if inverse_value == 0:
            return None, f"Cotação inversa inválida para {to_currency} -> {from_currency}"

        effective_rate = Decimal("1") / inverse_value
        converted_amount = amount * effective_rate

        return {
            "amount": _round_money(amount),
            "from_currency": from_currency,
            "to_currency": to_currency,
            "exchange_rate": _round_rate(effective_rate),
            "converted_amount": _round_money(converted_amount),
            "rate_date_used": inverse_rate.rate_date,
            "auto_synced": False,
        }, None

    if auto_sync:
        synced_rate, sync_error = await sync_exchange_rate_from_api(
            db=db,
            user_id=user_id,
            from_currency=from_currency,
            to_currency=to_currency,
            rate_date=rate_date,
        )

        if synced_rate:
            rate_value = Decimal(str(synced_rate.rate))
            converted_amount = amount * rate_value

            return {
                "amount": _round_money(amount),
                "from_currency": from_currency,
                "to_currency": to_currency,
                "exchange_rate": _round_rate(rate_value),
                "converted_amount": _round_money(converted_amount),
                "rate_date_used": synced_rate.rate_date,
                "auto_synced": True,
            }, None

        inverse_synced_rate, inverse_sync_error = await sync_exchange_rate_from_api(
            db=db,
            user_id=user_id,
            from_currency=to_currency,
            to_currency=from_currency,
            rate_date=rate_date,
        )

        if inverse_synced_rate:
            inverse_value = Decimal(str(inverse_synced_rate.rate))

            if inverse_value == 0:
                return None, (
                    f"Cotação sincronizada inválida para "
                    f"{to_currency} -> {from_currency}"
                )

            effective_rate = Decimal("1") / inverse_value
            converted_amount = amount * effective_rate

            return {
                "amount": _round_money(amount),
                "from_currency": from_currency,
                "to_currency": to_currency,
                "exchange_rate": _round_rate(effective_rate),
                "converted_amount": _round_money(converted_amount),
                "rate_date_used": inverse_synced_rate.rate_date,
                "auto_synced": True,
            }, None

        if sync_error:
            return None, sync_error

        if inverse_sync_error:
            return None, inverse_sync_error

    return None, f"Cotação não encontrada para {from_currency} -> {to_currency}"