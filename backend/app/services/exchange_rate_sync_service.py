from datetime import date, datetime
from decimal import Decimal
from sqlalchemy.orm import Session

from app.models.exchange_rate import ExchangeRate
from app.services.external_exchange_api_service import fetch_exchange_rate_from_api


async def sync_exchange_rate_from_api(
    db: Session,
    user_id: int,
    from_currency: str,
    to_currency: str,
    rate_date=None,
):
    from_currency = from_currency.upper().strip()
    to_currency = to_currency.upper().strip()
    effective_date = rate_date or date.today()

    result, error = await fetch_exchange_rate_from_api(
        from_currency=from_currency,
        to_currency=to_currency,
        rate_date=effective_date,
    )

    if error:
        return None, error

    if not result:
        return None, f"Não foi possível obter cotação para {from_currency} -> {to_currency}"

    rate_value = result.get("rate")
    result_from_currency = result.get("from_currency", from_currency).upper().strip()
    result_to_currency = result.get("to_currency", to_currency).upper().strip()
    result_rate_date = result.get("rate_date")

    if rate_value is None:
        return None, f"A API não retornou taxa para {from_currency} -> {to_currency}"

    rate_value = Decimal(str(rate_value))

    if rate_value <= 0:
        return None, f"Cotação inválida para {from_currency} -> {to_currency}"

    if result_rate_date:
        if isinstance(result_rate_date, str):
            parsed_date = datetime.strptime(result_rate_date, "%Y-%m-%d").date()
        else:
            parsed_date = result_rate_date
    else:
        parsed_date = effective_date

    existing = (
        db.query(ExchangeRate)
        .filter(
            ExchangeRate.user_id == user_id,
            ExchangeRate.from_currency == result_from_currency,
            ExchangeRate.to_currency == result_to_currency,
            ExchangeRate.rate_date == parsed_date,
        )
        .first()
    )

    if existing:
        existing.rate = rate_value
        db.commit()
        db.refresh(existing)
        return existing, None

    exchange_rate = ExchangeRate(
        from_currency=result_from_currency,
        to_currency=result_to_currency,
        rate=rate_value,
        rate_date=parsed_date,
        user_id=user_id,
    )

    db.add(exchange_rate)
    db.commit()
    db.refresh(exchange_rate)

    return exchange_rate, None