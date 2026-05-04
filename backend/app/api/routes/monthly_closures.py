from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session

from app.db.database import get_db
from app.api.deps import get_current_user
from app.models.user import User
from app.schemas.monthly_closure import (
    MonthlyClosureCreate,
    MonthlyClosureReopen,
    MonthlyClosureResponse,
)
from app.services.monthly_closure_service import (
    close_month,
    get_monthly_closure,
    reopen_month,
)

router = APIRouter(prefix="/monthly-closures", tags=["Monthly Closures"])


@router.post("/close", response_model=MonthlyClosureResponse, status_code=status.HTTP_201_CREATED)
def create_monthly_closure(
    payload: MonthlyClosureCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    closure, error = close_month(db, current_user.id, payload.year, payload.month)

    if error:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=error
        )

    return closure


@router.post("/reopen", status_code=status.HTTP_204_NO_CONTENT)
def reopen_monthly_closure(
    payload: MonthlyClosureReopen,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    error = reopen_month(db, current_user.id, payload.year, payload.month)

    if error:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=error
        )

    return


@router.get("/", response_model=MonthlyClosureResponse)
def read_monthly_closure(
    year: int = Query(...),
    month: int = Query(..., ge=1, le=12),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    closure = get_monthly_closure(db, current_user.id, year, month)

    if not closure:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Fechamento mensal não encontrado"
        )

    return closure