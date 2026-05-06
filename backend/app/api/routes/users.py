# app/api/routes/users.py

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.db.database import get_db
from app.api.deps import get_current_user, get_current_admin
from app.models.user import User
from app.schemas.user import UserResponse, UserUpdate, UserCreate, PasswordChange
from app.services.user_service import (
    update_base_currency,
    list_users,
    get_user_by_id,
    create_user_by_admin,
    admin_update_user,
    admin_update_user_password,
    admin_delete_user,
    update_user_profile,
    change_password,
)

router = APIRouter(prefix="/users", tags=["Users"])


@router.get("/", response_model=list[UserResponse])
def get_all_users(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_admin),
):
    """
    Lista todos os usuários (apenas admin)
    """
    return list_users(db)


@router.get("/me", response_model=UserResponse)
def get_me(
    current_user: User = Depends(get_current_user),
):
    """
    Retorna o usuário atual
    """
    return current_user


@router.put("/me/currency", response_model=UserResponse)
def update_me_currency(
    currency_data: dict,  # 👈 Mudado para dict em vez de CurrencyUpdateRequest
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """
    Atualiza a moeda base do usuário atual
    """
    new_currency = currency_data.get("base_currency")
    if not new_currency:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Moeda não informada"
        )
    
    user, error = update_base_currency(db, current_user, new_currency)
    if error:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=error
        )
    
    return user


@router.put("/me/profile", response_model=UserResponse)
def update_me_profile(
    profile_data: UserUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """
    Atualiza o perfil do usuário atual
    """
    user, error = update_user_profile(
        db=db,
        user_id=current_user.id,
        name=profile_data.name,
        email=profile_data.email,
        base_currency=profile_data.base_currency,
    )
    
    if error:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=error
        )
    
    return user


@router.post("/me/change-password")
def change_me_password(
    password_data: PasswordChange,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """
    Altera a senha do usuário atual
    """
    success, error = change_password(
        db=db,
        user_id=current_user.id,
        current_password=password_data.current_password,
        new_password=password_data.new_password,
    )
    
    if not success:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=error
        )
    
    return {"message": "Senha alterada com sucesso"}


@router.post("/", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
def create_user(
    user_data: UserCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_admin),
):
    """
    Cria um novo usuário (apenas admin)
    """
    user, error = create_user_by_admin(
        db=db,
        name=user_data.name,
        email=user_data.email,
        password=user_data.password,
        base_currency=user_data.base_currency,
        is_admin=user_data.is_admin,
    )
    
    if error:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=error
        )
    
    return user


@router.put("/{user_id}", response_model=UserResponse)
def update_user(
    user_id: int,
    user_data: UserUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_admin),
):
    """
    Atualiza um usuário (apenas admin)
    """
    user, error = admin_update_user(
        db=db,
        user_id=user_id,
        name=user_data.name,
        email=user_data.email,
        base_currency=user_data.base_currency,
        is_admin=user_data.is_admin,
    )
    
    if error:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=error
        )
    
    return user


@router.put("/{user_id}/password")
def update_user_password(
    user_id: int,
    password_data: dict,  # 👈 Mudado para dict
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_admin),
):
    """
    Altera a senha de um usuário (apenas admin)
    """
    new_password = password_data.get("new_password")
    if not new_password:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Nova senha não informada"
        )
    
    user, error = admin_update_user_password(
        db=db,
        user_id=user_id,
        new_password=new_password,
    )
    
    if error:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=error
        )
    
    return {"message": "Senha alterada com sucesso"}


@router.delete("/{user_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_user(
    user_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_admin),
):
    """
    Exclui um usuário (apenas admin)
    """
    success, error = admin_delete_user(db, user_id, current_user.id)
    
    if not success:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=error
        )
    
    return