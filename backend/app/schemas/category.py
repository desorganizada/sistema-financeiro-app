from pydantic import BaseModel


class CategoryCreate(BaseModel):
    name: str
    type: str
    group_name: str | None = None


class CategoryUpdate(BaseModel):
    name: str
    type: str
    group_name: str | None = None


class CategoryResponse(BaseModel):
    id: int
    name: str
    type: str
    group_name: str | None = None
    user_id: int

    class Config:
        from_attributes = True