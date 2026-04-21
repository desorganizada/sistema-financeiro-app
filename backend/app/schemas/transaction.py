from datetime import date
from decimal import Decimal
from pydantic import BaseModel


class TransactionCreate(BaseModel):
    description: str
    type: str
    amount_original: Decimal
    original_currency: str = "BRL"
    exchange_rate: Decimal | None = None
    date: date
    account_id: int
    category_id: int


class TransactionUpdate(BaseModel):
    description: str
    type: str
    amount_original: Decimal
    original_currency: str
    exchange_rate: Decimal | None = None
    date: date
    account_id: int
    category_id: int


class TransactionResponse(BaseModel):
    id: int
    description: str
    type: str
    amount_original: Decimal
    original_currency: str
    exchange_rate: Decimal
    amount_converted: Decimal
    date: date
    user_id: int
    account_id: int
    category_id: int

    class Config:
        from_attributes = True


class TransactionListResponse(BaseModel):
    items: list[TransactionResponse]
    total: int
    limit: int
    offset: int