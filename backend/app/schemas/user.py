# app/schemas/user.py

from pydantic import BaseModel, EmailStr
from typing import Optional


class UserBase(BaseModel):
    name: str
    email: EmailStr
    base_currency: str = "BRL"
    is_admin: bool = False


class UserCreate(UserBase):
    password: str


class UserUpdate(BaseModel):
    name: Optional[str] = None
    email: Optional[EmailStr] = None
    base_currency: Optional[str] = None
    is_admin: Optional[bool] = None


class UserResponse(UserBase):
    id: int

    class Config:
        from_attributes = True


class PasswordChange(BaseModel):
    current_password: str
    new_password: str  # 👈 estava "strc" (typo), agora corrigido para "str"