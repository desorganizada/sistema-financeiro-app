# app/services/auth_service.py

from datetime import datetime, timedelta
from jose import JWTError, jwt
from sqlalchemy.orm import Session

from app.models.user import User
from app.schemas.auth import UserRegister
from app.core.security import (
    verify_password,
    get_password_hash,
    create_access_token,
    create_refresh_token,
    decode_access_token,
    SECRET_KEY,
    ALGORITHM
)


def authenticate_user(db: Session, email: str, password: str):
    user = db.query(User).filter(User.email == email).first()
    if not user:
        return None
    if not verify_password(password, user.password_hash):
        return None
    return user


def login_user(db: Session, email: str, password: str):
    user = authenticate_user(db, email, password)
    if not user:
        return None, None
    
    access_token = create_access_token(data={"sub": str(user.id), "email": user.email})
    refresh_token = create_refresh_token(data={"sub": str(user.id), "email": user.email})
    
    return access_token, refresh_token


def refresh_access_token(db: Session, refresh_token: str):
    try:
        print(f"🔐 Attempting to refresh token...")
        payload = decode_access_token(refresh_token)
        
        # Verifica se é refresh token
        if payload.get("type") != "refresh":
            print("❌ Not a refresh token")
            return None
            
        user_id = payload.get("sub")
        if not user_id:
            print("❌ No user_id in token")
            return None
            
        user = db.query(User).filter(User.id == int(user_id)).first()
        if not user:
            print("❌ User not found")
            return None
            
        new_access_token = create_access_token(data={"sub": str(user.id), "email": user.email})
        print(f"🔐 New access token created for user: {user.email}")
        return new_access_token
    except Exception as e:
        print(f"❌ Refresh error: {e}")
        return None


def register_user(db: Session, user_data: UserRegister):
    existing_user = db.query(User).filter(User.email == user_data.email).first()
    if existing_user:
        return None
    
    hashed_password = get_password_hash(user_data.password)
    
    new_user = User(
        name=user_data.name,
        email=user_data.email,
        password_hash=hashed_password,
        base_currency=user_data.base_currency or "BRL",
        is_admin=user_data.is_admin or False
    )
    
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    
    return new_user