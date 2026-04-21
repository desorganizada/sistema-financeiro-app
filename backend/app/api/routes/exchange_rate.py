from datetime import date
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session

from app.db.database import get_db
from app.api.deps import get_current_user
from app.models.user import User
from app.schemas.exchange_rate import (
    ExchangeRateCreate,
    ExchangeRateUpdate,
    ExchangeRateResponse,
    CurrencyConvertRequest,
    CurrencyConvertResponse,
    ExchangeRateSyncRequest,
)
from app.services.exchange_rate_service import (
    create_exchange_rate,
    get_exchange_rates,
    get_exchange_rate_by_id,
    get_latest_exchange_rate,
    update_exchange_rate,
    delete_exchange_rate,
    convert_currency,
)
from app.services.exchange_rate_sync_service import sync_exchange_rate_from_api

router = APIRouter(prefix="/exchange-rates", tags=["Exchange Rates"])


@router.post("/convert", response_model=CurrencyConvertResponse)
async def convert_currency_endpoint(
    payload: CurrencyConvertRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    result, error = await convert_currency(
        db=db,
        user_id=current_user.id,
        amount=payload.amount,
        from_currency=payload.from_currency,
        to_currency=payload.to_currency,
        rate_date=payload.rate_date,
        auto_sync=payload.auto_sync,
    )

    if error:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=error,
        )

    return result


@router.get("/", response_model=list[ExchangeRateResponse])
def list_exchange_rates(
    from_currency: str | None = Query(default=None),
    to_currency: str | None = Query(default=None),
    rate_date: date | None = Query(default=None),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    return get_exchange_rates(
        db=db,
        user_id=current_user.id,
        from_currency=from_currency,
        to_currency=to_currency,
        rate_date=rate_date,
    )


@router.get("/latest", response_model=ExchangeRateResponse)
def latest_exchange_rate(
    from_currency: str = Query(...),
    to_currency: str = Query(...),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    exchange_rate = get_latest_exchange_rate(
        db=db,
        user_id=current_user.id,
        from_currency=from_currency,
        to_currency=to_currency,
    )

    if not exchange_rate:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Cotação não encontrada",
        )

    return exchange_rate


@router.post("/", response_model=ExchangeRateResponse, status_code=status.HTTP_201_CREATED)
def create_new_exchange_rate(
    payload: ExchangeRateCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    exchange_rate, error = create_exchange_rate(
        db=db,
        user_id=current_user.id,
        data=payload,
    )

    if error:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=error,
        )

    return exchange_rate


@router.put("/{exchange_rate_id}", response_model=ExchangeRateResponse)
def edit_exchange_rate(
    exchange_rate_id: int,
    payload: ExchangeRateUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    exchange_rate = get_exchange_rate_by_id(
        db=db,
        user_id=current_user.id,
        exchange_rate_id=exchange_rate_id,
    )

    if not exchange_rate:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Cotação não encontrada",
        )

    return update_exchange_rate(
        db=db,
        exchange_rate=exchange_rate,
        data=payload,
    )


@router.delete("/{exchange_rate_id}", status_code=status.HTTP_204_NO_CONTENT)
def remove_exchange_rate(
    exchange_rate_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    exchange_rate = get_exchange_rate_by_id(
        db=db,
        user_id=current_user.id,
        exchange_rate_id=exchange_rate_id,
    )

    if not exchange_rate:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Cotação não encontrada",
        )

    delete_exchange_rate(db, exchange_rate)
    return


@router.post("/sync", response_model=ExchangeRateResponse, status_code=status.HTTP_201_CREATED)
async def sync_exchange_rate(
    payload: ExchangeRateSyncRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    exchange_rate, error = await sync_exchange_rate_from_api(
        db=db,
        user_id=current_user.id,
        from_currency=payload.from_currency,
        to_currency=payload.to_currency,
        rate_date=payload.rate_date,
    )

    if error:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=error,
        )

    return exchange_rate