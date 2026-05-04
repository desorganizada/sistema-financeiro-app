from decimal import Decimal
from pydantic import BaseModel


class DashboardSummaryResponse(BaseModel):
    year: int
    month: int
    income: Decimal
    expense: Decimal
    investment: Decimal
    balance: Decimal
    transactions_count: int


class DashboardByCategoryResponse(BaseModel):
    category_id: int
    category_name: str
    type: str
    total: Decimal


class MonthlyEvolutionItem(BaseModel):
    month: int
    income: Decimal
    expense: Decimal
    investment: Decimal
    balance: Decimal


class BudgetVsActualItem(BaseModel):
    category_id: int
    category_name: str
    planned: Decimal
    actual: Decimal
    difference: Decimal


class DashboardPercentagesResponse(BaseModel):
    year: int
    month: int
    income: Decimal
    expense: Decimal
    investment: Decimal
    balance: Decimal
    expense_percentage: float
    investment_percentage: float
    balance_percentage: float