from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.db.database import get_db
from app.api.deps import get_current_user
from app.models.user import User
from app.schemas.account import (
    AccountCreate,
    AccountUpdate,
    AccountResponse,
    AccountBalanceResponse,
)
from app.services.account_service import (
    create_account,
    get_accounts,
    get_account_by_id,
    update_account,
    delete_account,
    get_account_balances,
)

router = APIRouter(prefix="/accounts", tags=["Accounts"])


@router.post("/", response_model=AccountResponse, status_code=status.HTTP_201_CREATED)
def create_new_account(
    account_data: AccountCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    return create_account(db, current_user.id, account_data)


@router.get("/", response_model=list[AccountResponse])
def list_accounts(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    return get_accounts(db, current_user.id)


@router.get("/balances", response_model=list[AccountBalanceResponse])
def list_account_balances(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    return get_account_balances(db, current_user.id)


@router.get("/{account_id}", response_model=AccountResponse)
def get_account(
    account_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    account = get_account_by_id(db, current_user.id, account_id)

    if not account:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Conta não encontrada"
        )

    return account


@router.put("/{account_id}", response_model=AccountResponse)
def edit_account(
    account_id: int,
    account_data: AccountUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    account = get_account_by_id(db, current_user.id, account_id)

    if not account:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Conta não encontrada"
        )

    return update_account(db, account, account_data)


@router.delete("/{account_id}", status_code=status.HTTP_204_NO_CONTENT)
def remove_account(
    account_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    account = get_account_by_id(db, current_user.id, account_id)

    if not account:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Conta não encontrada"
        )

    delete_account(db, account)
    return