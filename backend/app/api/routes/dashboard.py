from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from app.db.database import get_db
from app.api.deps import get_current_user
from app.models.user import User
from app.schemas.dashboard import (
    DashboardSummaryResponse,
    DashboardByCategoryResponse,
    MonthlyEvolutionItem,
    BudgetVsActualItem,
    DashboardPercentagesResponse,
)
from app.services.dashboard_service import (
    get_dashboard_summary,
    get_dashboard_by_category,
    get_monthly_evolution,
    get_budget_vs_actual,
    get_dashboard_percentages,
)

router = APIRouter(prefix="/dashboard", tags=["Dashboard"])


@router.get("/summary", response_model=DashboardSummaryResponse)
def summary(
    year: int = Query(..., examples=2026),
    month: int = Query(..., ge=1, le=12, examples=3),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    return get_dashboard_summary(db, current_user.id, year, month)


@router.get("/by-category", response_model=list[DashboardByCategoryResponse])
def by_category(
    year: int = Query(..., examples=2026),
    month: int = Query(..., ge=1, le=12, examples=3),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    return get_dashboard_by_category(db, current_user.id, year, month)


@router.get("/monthly-evolution", response_model=list[MonthlyEvolutionItem])
def monthly_evolution(
    year: int = Query(..., examples=2026),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    return get_monthly_evolution(db, current_user.id, year)


@router.get("/budget-vs-actual", response_model=list[BudgetVsActualItem])
def budget_vs_actual(
    year: int = Query(..., examples=2026),
    month: int = Query(..., ge=1, le=12, examples=3),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    return get_budget_vs_actual(db, current_user.id, year, month)


@router.get("/percentages", response_model=DashboardPercentagesResponse)
def percentages(
    year: int = Query(..., examples=2026),
    month: int = Query(..., ge=1, le=12, examples=3),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    return get_dashboard_percentages(db, current_user.id, year, month)