from pydantic import BaseModel, EmailStr, Field, ConfigDict


class UserCreate(BaseModel):
    name: str
    email: EmailStr
    password: str = Field(..., min_length=6, max_length=60)


class UserResponse(BaseModel):
    id: int
    name: str
    email: EmailStr
    base_currency: str
    is_admin: bool

    model_config = ConfigDict(from_attributes=True)


class UpdateBaseCurrency(BaseModel):
    base_currency: str


class AdminUserCreate(BaseModel):
    name: str
    email: EmailStr
    password: str = Field(..., min_length=6, max_length=60)
    base_currency: str = "BRL"
    is_admin: bool = False


class AdminUserUpdate(BaseModel):
    name: str
    email: EmailStr
    base_currency: str
    is_admin: bool


class AdminUserPasswordUpdate(BaseModel):
    new_password: str = Field(..., min_length=6, max_length=60)


class AdminUserListItem(BaseModel):
    id: int
    name: str
    email: EmailStr
    base_currency: str
    is_admin: bool

    model_config = ConfigDict(from_attributes=True)