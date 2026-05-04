from sqlalchemy.orm import Session

from app.models.user import User
from app.core.currencies import SUPPORTED_CURRENCIES
from app.core.security import hash_password


def update_base_currency(db: Session, user: User, new_currency: str):
    new_currency = new_currency.upper()

    if new_currency not in SUPPORTED_CURRENCIES:
        return None, "Moeda não suportada"

    user.base_currency = new_currency
    db.commit()
    db.refresh(user)

    return user, None


def list_users(db: Session):
    return db.query(User).order_by(User.id.asc()).all()


def get_user_by_id(db: Session, user_id: int):
    return db.query(User).filter(User.id == user_id).first()


def create_user_by_admin(
    db: Session,
    name: str,
    email: str,
    password: str,
    base_currency: str,
    is_admin: bool,
):
    existing_user = db.query(User).filter(User.email == email).first()
    if existing_user:
        return None, "E-mail já cadastrado"

    base_currency = base_currency.upper()
    if base_currency not in SUPPORTED_CURRENCIES:
        return None, "Moeda não suportada"

    user = User(
        name=name,
        email=email,
        password_hash=hash_password(password),
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
    user = get_user_by_id(db, user_id)
    if not user:
        return None, "Usuário não encontrado"

    base_currency = base_currency.upper()
    if base_currency not in SUPPORTED_CURRENCIES:
        return None, "Moeda não suportada"

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
    user = get_user_by_id(db, user_id)
    if not user:
        return None, "Usuário não encontrado"

    user.password_hash = hash_password(new_password)

    db.commit()
    db.refresh(user)

    return user, None


def admin_delete_user(db: Session, user_id: int, current_admin_id: int):
    user = get_user_by_id(db, user_id)

    if not user:
        return False, "Usuário não encontrado"

    if user.id == current_admin_id:
        return False, "Você não pode excluir seu próprio usuário administrador"

    db.delete(user)
    db.commit()

    return True, None