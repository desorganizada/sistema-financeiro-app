from decimal import Decimal
from pydantic import BaseModel


class BudgetCreate(BaseModel):
    year: int
    month: int
    category_id: int
    planned_amount: Decimal


class BudgetUpdate(BaseModel):
    year: int
    month: int
    category_id: int
    planned_amount: Decimal


class BudgetResponse(BaseModel):
    id: int
    year: int
    month: int
    planned_amount: Decimal
    user_id: int
    category_id: int

    class Config:
        from_attributes = True