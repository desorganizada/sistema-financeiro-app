from decimal import Decimal
from datetime import datetime
from pydantic import BaseModel


class MonthlyClosureCreate(BaseModel):
    year: int
    month: int


class MonthlyClosureReopen(BaseModel):
    year: int
    month: int


class MonthlyClosureResponse(BaseModel):
    id: int
    year: int
    month: int
    income: Decimal
    expense: Decimal
    investment: Decimal
    balance: Decimal
    transactions_count: int
    closed_at: datetime
    user_id: int

    class Config:
        from_attributes = True