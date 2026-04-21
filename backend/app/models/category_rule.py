from sqlalchemy import Column, Integer, String, ForeignKey
from app.db.database import Base


class CategoryRule(Base):
    __tablename__ = "category_rules"

    id = Column(Integer, primary_key=True, index=True)
    keyword = Column(String, nullable=False)
    priority = Column(Integer, nullable=False, default=0)

    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    category_id = Column(Integer, ForeignKey("categories.id"), nullable=False)