from pydantic import BaseModel


class CategoryRuleCreate(BaseModel):
    keyword: str
    priority: int = 0
    category_id: int


class CategoryRuleUpdate(BaseModel):
    keyword: str
    priority: int = 0
    category_id: int


class CategoryRuleResponse(BaseModel):
    id: int
    keyword: str
    priority: int
    user_id: int
    category_id: int

    class Config:
        from_attributes = True