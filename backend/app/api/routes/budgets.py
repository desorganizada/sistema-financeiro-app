from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session

from app.db.database import get_db
from app.api.deps import get_current_user
from app.models.user import User
from app.schemas.budget import BudgetCreate, BudgetUpdate, BudgetResponse
from app.services.budget_service import (
    create_budget,
    get_budgets,
    get_budget_by_id,
    update_budget,
    delete_budget,
)

router = APIRouter(prefix="/budgets", tags=["Budgets"])


@router.post("/", response_model=BudgetResponse, status_code=status.HTTP_201_CREATED)
def create_new_budget(
    budget_data: BudgetCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    budget, error = create_budget(db, current_user.id, budget_data)

    if error:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=error
        )

    return budget


@router.get("/", response_model=list[BudgetResponse])
def list_budgets(
    year: int = Query(...),
    month: int = Query(..., ge=1, le=12),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    return get_budgets(db, current_user.id, year, month)


@router.put("/{budget_id}", response_model=BudgetResponse)
def edit_budget(
    budget_id: int,
    budget_data: BudgetUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    budget = get_budget_by_id(db, current_user.id, budget_id)

    if not budget:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Orçamento não encontrado"
        )

    updated_budget, error = update_budget(db, current_user.id, budget, budget_data)

    if error:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=error
        )

    return updated_budget


@router.delete("/{budget_id}", status_code=status.HTTP_204_NO_CONTENT)
def remove_budget(
    budget_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    budget = get_budget_by_id(db, current_user.id, budget_id)

    if not budget:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Orçamento não encontrado"
        )

    delete_budget(db, budget)
    return