from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from decimal import Decimal
from typing import Dict, Any

from app.db.database import get_db
from app.api.deps import get_current_user
from app.models.user import User
from app.models.account import Account
from app.models.transaction import Transaction
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
from app.services.currency_conversion_service import get_applicable_exchange_rate

router = APIRouter(prefix="/accounts", tags=["Accounts"])


@router.post("/", response_model=AccountResponse, status_code=status.HTTP_201_CREATED)
async def create_new_account(
    account_data: AccountCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    return await create_account(db, current_user.id, account_data)


@router.get("/", response_model=list[AccountResponse])
def list_accounts(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Retorna todas as contas do usuário (valores ORIGINAIS sem conversão)"""
    return get_accounts(db, current_user.id)


@router.get("/with-original-balance")
def list_accounts_with_original_balance(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """
    Retorna todas as contas com saldo na moeda ORIGINAL (SEM conversão)
    Este endpoint é usado pela página de contas do Flutter
    """
    accounts = get_accounts(db, current_user.id)
    result = []
    
    for account in accounts:
        # Busca todas as transações da conta
        transactions = db.query(Transaction).filter(
            Transaction.user_id == current_user.id,
            Transaction.account_id == account.id
        ).all()
        
        # Calcula o saldo na moeda ORIGINAL da conta
        original_balance = Decimal("0.00")
        for transaction in transactions:
            original_balance += Decimal(str(transaction.amount_original or 0))
        
        result.append({
            "id": account.id,
            "name": account.name,
            "type": account.type,
            "currency": account.currency,  # Moeda original (USD, EUR, etc.)
            "balance": float(original_balance),  # Saldo na moeda original
        })
    
    return result


@router.get("/balances", response_model=list[AccountBalanceResponse])
def list_account_balances(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Retorna saldos das contas (com conversão para moeda base do usuário)"""
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
async def edit_account(
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
    return await update_account(db, account, account_data)


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