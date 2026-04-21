from decimal import Decimal
from pydantic import BaseModel
from typing import Optional
from datetime import date


class AccountCreate(BaseModel):
    name: str
    type: str
    currency: str
    initial_balance: Decimal = Decimal("0.00")
    initial_balance_date: Optional[date] = None


class AccountUpdate(BaseModel):
    name: str
    type: str
    currency: str
    initial_balance: Decimal = Decimal("0.00")
    initial_balance_date: Optional[date] = None


class AccountResponse(BaseModel):
    id: int
    name: str
    type: str
    currency: str
    user_id: int

    class Config:
        from_attributes = True


class AccountBalanceResponse(BaseModel):
    account_id: int
    account_name: str
    currency: str
    income: Decimal
    expense: Decimal
    investment: Decimal
    balance: Decimal