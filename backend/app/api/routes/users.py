from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.db.database import get_db
from app.api.deps import get_current_user, get_current_admin
from app.models.user import User
from app.schemas.user import (
    UpdateBaseCurrency,
    UserResponse,
    AdminUserCreate,
    AdminUserUpdate,
    AdminUserPasswordUpdate,
    AdminUserListItem,
)
from app.services.user_service import (
    update_base_currency,
    list_users,
    create_user_by_admin,
    admin_update_user,
    admin_update_user_password,
    admin_delete_user,
)

router = APIRouter(prefix="/users", tags=["Users"])


@router.put("/base-currency", response_model=UserResponse)
def change_base_currency(
    payload: UpdateBaseCurrency,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    user, error = update_base_currency(db, current_user, payload.base_currency)

    if error:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=error,
        )

    return user


@router.get("/admin", response_model=list[AdminUserListItem])
def admin_list_users(
    db: Session = Depends(get_db),
    current_admin: User = Depends(get_current_admin),
):
    return list_users(db)


@router.post("/admin", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
def admin_create_user(
    payload: AdminUserCreate,
    db: Session = Depends(get_db),
    current_admin: User = Depends(get_current_admin),
):
    user, error = create_user_by_admin(
        db=db,
        name=payload.name,
        email=payload.email,
        password=payload.password,
        base_currency=payload.base_currency,
        is_admin=payload.is_admin,
    )

    if error:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=error,
        )

    return user


@router.put("/admin/{user_id}", response_model=UserResponse)
def admin_edit_user(
    user_id: int,
    payload: AdminUserUpdate,
    db: Session = Depends(get_db),
    current_admin: User = Depends(get_current_admin),
):
    user, error = admin_update_user(
        db=db,
        user_id=user_id,
        name=payload.name,
        email=payload.email,
        base_currency=payload.base_currency,
        is_admin=payload.is_admin,
    )

    if error:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=error,
        )

    return user


@router.put("/admin/{user_id}/password", response_model=UserResponse)
def admin_change_user_password(
    user_id: int,
    payload: AdminUserPasswordUpdate,
    db: Session = Depends(get_db),
    current_admin: User = Depends(get_current_admin),
):
    user, error = admin_update_user_password(
        db=db,
        user_id=user_id,
        new_password=payload.new_password,
    )

    if error:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=error,
        )

    return user


@router.delete("/admin/{user_id}")
def admin_remove_user(
    user_id: int,
    db: Session = Depends(get_db),
    current_admin: User = Depends(get_current_admin),
):
    success, error = admin_delete_user(db, user_id, current_admin.id)

    if error:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=error,
        )

    return {"message": "Usuário excluído com sucesso"}