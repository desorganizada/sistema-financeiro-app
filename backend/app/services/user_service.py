# app/services/user_service.py

from sqlalchemy.orm import Session

from app.models.user import User
from app.core.currencies import SUPPORTED_CURRENCIES
from app.core.security import get_password_hash, verify_password


def update_base_currency(db: Session, user: User, new_currency: str):
    """
    Atualiza a moeda base do usuário
    """
    new_currency = new_currency.upper()

    if new_currency not in SUPPORTED_CURRENCIES:
        return None, "Moeda não suportada"

    user.base_currency = new_currency
    db.commit()
    db.refresh(user)

    return user, None


def list_users(db: Session):
    """
    Lista todos os usuários
    """
    return db.query(User).order_by(User.id.asc()).all()


def get_user_by_id(db: Session, user_id: int):
    """
    Busca usuário por ID
    """
    return db.query(User).filter(User.id == user_id).first()


def get_user_by_email(db: Session, email: str):
    """
    Busca usuário por email
    """
    return db.query(User).filter(User.email == email).first()


def create_user_by_admin(
    db: Session,
    name: str,
    email: str,
    password: str,
    base_currency: str,
    is_admin: bool,
):
    """
    Cria um novo usuário pelo administrador
    """
    existing_user = get_user_by_email(db, email)
    if existing_user:
        return None, "E-mail já cadastrado"

    base_currency = base_currency.upper()
    if base_currency not in SUPPORTED_CURRENCIES:
        return None, "Moeda não suportada"

    user = User(
        name=name,
        email=email,
        hashed_password=hash_password(password),
        base_currency=base_currency,
        is_admin=is_admin,
    )

    db.add(user)
    db.commit()
    db.refresh(user)

    return user, None


def admin_update_user(
    db: Session,
    user_id: int,
    name: str,
    email: str,
    base_currency: str,
    is_admin: bool,
):
    """
    Atualiza dados do usuário pelo administrador
    """
    user = get_user_by_id(db, user_id)
    if not user:
        return None, "Usuário não encontrado"

    base_currency = base_currency.upper()
    if base_currency not in SUPPORTED_CURRENCIES:
        return None, "Moeda não suportada"

    # Verifica se o novo email já está em uso por outro usuário
    existing_user = db.query(User).filter(
        User.email == email,
        User.id != user_id,
    ).first()

    if existing_user:
        return None, "Já existe outro usuário com este e-mail"

    user.name = name
    user.email = email
    user.base_currency = base_currency
    user.is_admin = is_admin

    db.commit()
    db.refresh(user)

    return user, None


def admin_update_user_password(
    db: Session,
    user_id: int,
    new_password: str,
):
    """
    Atualiza a senha do usuário pelo administrador
    """
    user = get_user_by_id(db, user_id)
    if not user:
        return None, "Usuário não encontrado"

    user.password_hash = hash_password(new_password)

    db.commit()
    db.refresh(user)

    return user, None


def admin_delete_user(db: Session, user_id: int, current_admin_id: int):
    """
    Exclui um usuário pelo administrador
    """
    user = get_user_by_id(db, user_id)

    if not user:
        return False, "Usuário não encontrado"

    if user.id == current_admin_id:
        return False, "Você não pode excluir seu próprio usuário administrador"

    db.delete(user)
    db.commit()

    return True, None


def update_user_profile(
    db: Session,
    user_id: int,
    name: str = None,
    email: str = None,
    base_currency: str = None,
):
    """
    Atualiza o perfil do próprio usuário
    """
    user = get_user_by_id(db, user_id)
    if not user:
        return None, "Usuário não encontrado"

    if name:
        user.name = name

    if email:
        # Verifica se o novo email já está em uso
        existing_user = db.query(User).filter(
            User.email == email,
            User.id != user_id,
        ).first()
        if existing_user:
            return None, "Este e-mail já está em uso"
        user.email = email

    if base_currency:
        base_currency = base_currency.upper()
        if base_currency not in SUPPORTED_CURRENCIES:
            return None, "Moeda não suportada"
        user.base_currency = base_currency

    db.commit()
    db.refresh(user)

    return user, None


def change_password(
    db: Session,
    user_id: int,
    current_password: str,
    new_password: str,
):
    """
    Altera a senha do próprio usuário
    """
    user = get_user_by_id(db, user_id)
    if not user:
        return False, "Usuário não encontrado"

    # Verifica a senha atual
    if not verify_password(current_password, user.password_hash):
        return False, "Senha atual incorreta"

    # Atualiza a senha
    user.password_hash = hash_password(new_password)
    db.commit()

    return True, None