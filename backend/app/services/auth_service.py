from sqlalchemy.orm import Session
from app.models.user import User
from app.schemas.auth import UserRegister
from app.core.security import hash_password, verify_password, create_access_token
from app.services.default_categories import create_default_categories


def get_user_by_email(db: Session, email: str):
    return db.query(User).filter(User.email == email).first()


def register_user(db: Session, user_data: UserRegister):
    existing_user = get_user_by_email(db, user_data.email)
    if existing_user:
        return None

    new_user = User(
        name=user_data.name,
        email=user_data.email,
        password_hash=hash_password(user_data.password),
        base_currency="BRL"
    )

    db.add(new_user)
    db.commit()
    db.refresh(new_user)

    create_default_categories(db, new_user.id)

    return new_user


def authenticate_user(db: Session, email: str, password: str):
    user = get_user_by_email(db, email)
    if not user:
        return None

    if not verify_password(password, user.password_hash):
        return None

    return user


def login_user(db: Session, email: str, password: str):
    user = authenticate_user(db, email, password)
    if not user:
        return None

    token = create_access_token({"sub": str(user.id), "email": user.email})
    return token