from datetime import date
from decimal import Decimal
from pydantic import BaseModel


class ExchangeRateCreate(BaseModel):
    from_currency: str
    to_currency: str
    rate: Decimal
    rate_date: date


class ExchangeRateUpdate(BaseModel):
    from_currency: str
    to_currency: str
    rate: Decimal
    rate_date: date


class ExchangeRateResponse(BaseModel):
    id: int
    from_currency: str
    to_currency: str
    rate: Decimal
    rate_date: date
    user_id: int

    class Config:
        from_attributes = True


class ExchangeRateSyncRequest(BaseModel):
    from_currency: str
    to_currency: str
    rate_date: date | None = None


class CurrencyConvertRequest(BaseModel):
    amount: Decimal
    from_currency: str
    to_currency: str
    rate_date: date | None = None
    auto_sync: bool = True


class CurrencyConvertResponse(BaseModel):
    amount: Decimal
    from_currency: str
    to_currency: str
    exchange_rate: Decimal
    converted_amount: Decimal
    rate_date_used: date
    auto_synced: bool = False